class AcmeStatePaths {
    [string] $BasePath;

    [string] $ServiceDirectory;
    [string] $Nonce;
    [string] $AccountKey;
    [string] $Account;

    [string] $OrderList;
    hidden [string] $Order;

    AcmeStatePaths([string] $basePath) {
        $this.BasePath = Resolve-Path $basePath

        $this.ServiceDirectory = "$($this.BasePath)/ServiceDirectory.xml";
        $this.Nonce = "$($this.BasePath)/NextNonce.txt";
        $this.AccountKey = "$($this.BasePath)AccountKey.xml";
        $this.Account = "$($this.BasePath)Account.xml";

        $this.OrderList = "$($this.BasePath)Orders/OrderList.txt"
        $this.Order = "$($this.BasePath)Orders/Order-[hash].xml";
    }

    [string] GetOrderFileName([string] $orderHash) {
        return $this.Order.Replace("[hash]", $orderHash);
    }
}

class AcmeDiskPersistedState {
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
            $result = Import-AccountKEy -Path $fileName;
            return $result;
        }

        Write-Verbose "Could not find saved account key at $fileName."
        return $null;
    }

    [AcmeAccount] GetAccount() {
        $fileName = $this.Filenames.AccountKey;

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
    hidden [string] GetOrderHash([AcmeOrder] $order) {
        $orderIdentifiers = $order.Identifiers | Foreach-Object { $_.ToString() } | Sort-Object;
        $identifier = [string]::Join('|', $orderIdentifiers);

        $sha256 = [System.Security.Cryptography.SHA256]::Create();
        try {
            $identifierBytes = [System.Text.Encoding]::UTF8.GetBytes($identifier);
            $identifierHash = $sha256.ComputeHash($identifierBytes);
            $result = ConvertTo-UrlBase64 -InputBytes $identifierHash;

            return $result;
        } finally {
            $sha256.Dispose();
        }
    }

    hidden [AcmeOrder] LoadOrder([string] $orderHash) {
        $orderFile = $this.Filenames.GetOrderFileName($orderHash);
        if(Test-Path $orderFile) {
            $order = Import-AcmeObject -Path $orderFile -TypeName "AcmeOrder";
            return $order;
        }

        return $null;
    }

    [AcmeOrder] FindOrder([string[]] $dnsNames) {
        $orderListFile = $this.Filenames.OrderList;

        $first = $true;
        $lastMatch = $null;
        foreach($dnsName in $dnsNames) {
            $match = Select-String -Path $orderListFile -Pattern "$dnsName=" -SimpleMatch | Select-Object -Last 1
            if($first) { $lastMatch = $match; }
            if($match -ne $lastMatch) { return $null; }

            $lastMatch = $match;
        }

        $orderHash = ($lastMatch -split "=", 2)[1];
        return $this.LoadOrder($orderHash);
    }

    [void] AddOrder([AcmeOrder] $order) {
        $this.SetOrder($order);
    }

    [void] SetOrder([AcmeOrder] $order) {
        $orderHash = $this.GetOrderHash($order);
        $orderFileName = $this.Filenames.GetOrderFileName($orderHash);

        if(-not (Test-Path $order)) {
            $orderListFile = $this.Filenames.OrderList;

            foreach ($id in $order.Identifiers) {
                if(-not (Test-Path $orderListFile)) {
                    New-Item $orderListFile -Force;
                }

                "$($id.ToString())=$orderHash" | Add-Content $orderListFile;
            }
        }

        $order | Export-AcmeObject $orderFileName -Force;
    }

    [void] RemoveOrder([AcmeOrder] $order) {
        $orderHash = $this.GetOrderHash($order);
        $orderFileName = $this.Filenames.GetOrderFileName($orderHash);

        if(Test-Path $orderFileName) {
            Remove-Item $orderFileName;
        }

        $orderListFile = $this.Filenames.OrderList;
        Set-Content -Path $orderListFile -Value (Get-Content -Path $orderListFile | Select-String -Pattern "=$orderHash" -NotMatch -SimpleMatch)
    }
}
