function New-ExternalAccountPayload {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function", Target="*")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountKeyExists()})]
        [AcmeState]
        $State,

        [Parameter(ParameterSetName = "ExternalAccountBinding", Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $ExternalAccountKID,

        [Parameter(ParameterSetName = "ExternalAccountBinding")]
        [ValidateSet('HS256','HS384','HS512')]
        [string]
        $ExternalAccountAlgorithm = 'HS256',

        [Parameter(ParameterSetName = "ExternalAccountBinding", Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $ExternalAccountMACKey
    )

    process {
        $macKeyBytes = ConvertFrom-UrlBase64 $ExternalAccountMACKey;
        $macAlgorithm = switch ($ExternalAccountAlgorithm) {
            "HS256" { [Security.Cryptography.HMACSHA256]::new($macKeyBytes); break; }
            "HS384" { [Security.Cryptography.HMACSHA384]::new($macKeyBytes); break; }
            "HS512" { [Security.Cryptography.HMACSHA512]::new($macKeyBytes); break; }
        }

        $eaHeader = @{
            "alg" = $ExternalAccountAlgorithm;
            "kid" = $ExternalAccountKID;
            "url" = $url;
        } | ConvertTo-Json -Compress | ConvertTo-UrlBase64
        $eaPayload = $State.GetAccountKey().ExportPublicJwk() | ConvertTo-Json -Compress | ConvertTo-UrlBase64;

        $eaHashContent = [Text.Encoding]::ASCII.GetBytes("$($eaHeader).$($eaPayload)");
        $eaSignature = (ConvertTo-UrlBase64 -InputBytes $macAlgorithm.ComputeHash($eaHashContent));

        $externalAccountBinding = @{
            "protected" = $eaHeader;
            "payload" = $eaPayload;
            "signature" = $eaSignature;
        };

        return $externalAccountBinding;
    }
}