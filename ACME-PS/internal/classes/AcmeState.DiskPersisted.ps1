class AcmeStatePaths {
    [string] $BasePath;

    [string] $ServiceDirectory;
    [string] $Nonce;
    [string] $AccountKey;
    [string] $Account;

    [string] $OrderList;
    hidden [string] $Order;

    AcmeStatePaths([string] $basePath) {
        $this.BasePath = [System.IO.Path]::GetFullPath($basePath).TrimEnd('/', '\');

        $this.ServiceDirectory = [System.IO.Path]::Combine($this.BasePath, "ServiceDirectory.xml");
        $this.Nonce = [System.IO.Path]::Combine($this.BasePath, "NextNonce.txt");
        $this.AccountKey = [System.IO.Path]::Combine($this.BasePath, "AccountKey.xml");
        $this.Account = [System.IO.Path]::Combine($this.BasePath, "Account.xml");

        $this.OrderList = [System.IO.Path]::Combine($this.BasePath, "Orders", "OrderList.txt");
        $this.Order = [System.IO.Path]::Combine($this.BasePath, "Orders", "Order-[hash].xml");
    }

    [string] GetOrderFilename([string] $orderHash) {
        return $this.Order.Replace("[hash]", $orderHash);
    }

    [string] GetOrderCertificateKeyFilename([string] $orderHash) {
        $orderFilename = $this.GetOrderFilename($orderHash);
        return [System.IO.Path]::ChangeExtension($orderFilename, "key.xml");
    }

    [string] GetOrderCertificateFilename([string] $orderHash) {
        $orderFilename = $this.GetOrderFilename($orderHash);
        return [System.IO.Path]::ChangeExtension($orderFilename, "pem");
    }
}

class AcmeDiskPersistedState : AcmeState {
    hidden [AcmeStatePaths] $Filenames;

    AcmeDiskPersistedState([AcmeStatePaths] $paths, [bool] $createState, [bool] $allowLateInit) {
        $this.Filenames = $paths;

        if(-not (Test-Path $this.Filenames.BasePath)) {
            if ($createState) {
                New-Item $this.Filenames.BasePath -ItemType Directory -Force -ErrorAction 'Stop';
            } else {
                throw "$($this.Filenames.BasePath) does not exist.";
            }
        }

        $flagFile = "$($this.Filenames.BasePath)/.acme-ps-state";
        if(-not (Test-Path $flagFile)) {
            if($allowLateInit -or $createState) {
                New-Item $flagFile -ItemType File
            } else {
                throw "Could not find $flagFile identifying the state directory. You can create an empty file, to fix this.";
            }
        } else {
            # Test, if the path seems writable.
            Set-Content -Path $flagFile -Value (Get-Date) -ErrorAction 'Stop';
        }
    }


    <# Getters #>
    [string] GetNonce() {
        $fileName = $this.Filenames.Nonce;

        if(Test-Path $fileName) {
            $result = Get-Content $fileName -Raw
            return $result;
        }

        Write-Verbose "Could not find saved nonce at $fileName";
        return $null;
    }

    [AcmeDirectory] GetServiceDirectory() {
        $fileName = $this.Filenames.ServiceDirectory;

        if(Test-Path $fileName) {
            if($fileName -like "*.json") {
                $result = [ACMEDirectory](Get-Content $fileName | ConvertFrom-Json)
            } else {
                $result = [AcmeDirectory](Import-Clixml $fileName)
            }

            return $result;
        }

        Write-Verbose "Could not find saved service directory at $fileName";
        return $null;
    }

    [IAccountKey] GetAccountKey() {
        $fileName = $this.Filenames.AccountKey;

        if(Test-Path $fileName) {
            $result = Import-AccountKey -Path $fileName;
            return $result;
        }

        Write-Verbose "Could not find saved account key at $fileName."
        return $null;
    }

    [AcmeAccount] GetAccount() {
        $fileName = $this.Filenames.Account;

        if(Test-Path $fileName) {
            $result = Import-AcmeObject -Path $fileName -TypeName "AcmeAccount";
            return $result;
        }

        Write-Verbose "Could not find saved account key at $fileName."
        return $null;
    }


    <# Setters #>
    [void] SetNonce([string] $value) {
        $fileName = $this.Filenames.Nonce;

        Write-Debug "Storing the nonce to $fileName"
        Set-Content $fileName -Value $value -NoNewLine;
    }

    [void] Set([AcmeDirectory] $value) {
        $fileName = $this.Filenames.ServiceDirectory;

        Write-Debug "Storing the service directory to $fileName";
        $value | Export-AcmeObject $fileName -Force;
    }

    [void] Set([IAccountKey] $value) {
        $fileName = $this.Filenames.AccountKey;

        Write-Debug "Storing the account key to $fileName";
        $value | Export-AccountKey $fileName -Force;
    }

    [void] Set([AcmeAccount] $value) {
        $fileName = $this.Filenames.Account;

        Write-Debug "Storing the account data to $fileName";
        $value | Export-AcmeObject $fileName;
    }

    <# Orders #>
    hidden [AcmeOrder] LoadOrder([string] $orderHash) {
        $orderFile = $this.Filenames.GetOrderFilename($orderHash);
        if(Test-Path $orderFile) {
            $order = Import-AcmeObject -Path $orderFile -TypeName "AcmeOrder";
            return $order;
        }

        return $null;
    }

    [AcmeOrder] FindOrder([string[]] $names) {
        $orderListFile = $this.Filenames.OrderList;

        $first = $true;
        $lastMatch = $null;
        foreach($name in $names) {
            $match = Select-String -Path $orderListFile -Pattern "$name=" -SimpleMatch | Select-Object -Last 1
            if($first) { $lastMatch = $match; }
            if($match -ne $lastMatch) { return $null; }

            $lastMatch = $match;
        }

        $orderHash = ($lastMatch -split "=", 2)[1];
        return $this.LoadOrder($orderHash);
    }

    [AcmeOrder] FindOrder([AcmeIdentifier[]] $identifiers) {
        $names = $identifiers | ForEach-Object { $_.ToString() };
        return $this.FindOrder($names);
    }

    [void] AddOrder([AcmeOrder] $order) {
        $this.SetOrder($order);
    }

    [void] SetOrder([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $orderFileName = $this.Filenames.GetOrderFilename($orderHash);

        if(-not (Test-Path $order)) {
            $orderListFile = $this.Filenames.OrderList;

            foreach ($id in $order.Identifiers) {
                if(-not (Test-Path $orderListFile)) {
                    New-Item $orderListFile -Force;
                }

                $match = Select-String -Path $orderListFile -Pattern "$($id.ToString())=" -SimpleMatch | Select-Object -Last 1
                if($null -eq $match) {
                    "$($id.ToString())=$orderHash" | Add-Content $orderListFile;
                }
            }
        }

        $order | Export-AcmeObject $orderFileName -Force;
    }

    [void] RemoveOrder([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $orderFileName = $this.Filenames.GetOrderFilename($orderHash);

        if(Test-Path $orderFileName) {
            Remove-Item $orderFileName;
        }

        $orderListFile = $this.Filenames.OrderList;
        Set-Content -Path $orderListFile -Value (Get-Content -Path $orderListFile | Select-String -Pattern "=$orderHash" -NotMatch -SimpleMatch)
    }


    [ICertificateKey] GetOrderCertificateKey([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $certKeyFilename = $this.Filenames.GetOrderCertificateKeyFilename($orderHash);
        
        if(Test-Path $certKeyFilename) {
            return (Import-CertificateKey -Path $certKeyFilename);
        }

        return $null;
    }

    [void] SetOrderCertificateKey([AcmeOrder] $order, [ICertificateKey] $certificateKey) {
        $orderHash = $order.GetHashString();
        $certKeyFilename = $this.Filenames.GetOrderCertificateKeyFilename($orderHash);
        
        $certificateKey | Export-CertificateKey -Path $certKeyFilename
    }


    [byte[]] GetOrderCertificate([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $certFilename = $this.Filenames.GetOrderCertificateFilename($orderHash);

        return Get-ByteContent -Path $certFilename;
    }

    [void] SetOrderCertificate([AcmeOrder] $order, [byte[]] $certificate) {
        $orderHash = $order.GetHashString();
        $certFilename = $this.Filenames.GetOrderCertificateFilename($orderHash);

        Set-ByteContent -Path $certFilename -Content $certificate;
    }

}
