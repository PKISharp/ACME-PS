function Invoke-SignedWebRequest {
    <#
        .SYNOPSIS
            Sends a POST request to the given URL.

        .DESCRIPTION
            Sends a POST request to the given URL. It'll use the account, account key and
            nonce provided in the state object to sign the request and add the anti-replay-nonce.
            The request will automatically retry, if there's a nonce-error unless indicated otherwise.
            Generally this CmdLet is used internally only, but it's available publically since, it might be usefull.


        .PARAMETER Url
            The url where the POST or POST-as-GET request should be sent.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Payload
            The payload of the request. Will be signed if present.
            Leave empty for POST-as-GET requests.

        .PARAMETER SuppressKeyId
            Do not include the KeyId parameter in the request.

        .PARAMETER SkipRetryOnNonceError
            Do not retry the request on nonce-errors.

        .PARAMETER SigningKey
            Will be used to sign the request to the acme server.

        .EXAMPLE
            PS (POST-as-GET)> Invoke-SignedWebRequest "https://acme.service/" $myState
            PS (POST-as-GET)> Invoke-SignedWebRequest -Url "https://acme.service/" -State $myState -Payload $myPayload
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType("AcmeHttpResponse")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [AcmeState] $State,

        [Parameter(Position = 2)]
        [ValidateNotNull()]
        [object] $Payload = "",

        [Parameter()]
        [Alias("SupressKeyId")]
        [switch] $SuppressKeyId,

        [Parameter()]
        [switch] $SkipRetryOnNonceError,

        [Parameter(ParameterSetName = "HasSigningKey")]
        [ValidateNotNull()]
        [AcmePSKey] $SigningKey
    )

    process {
        $nonce = $State.GetNonce();
        if($PsCmdlet.ParameterSetName -ne "HasSigningKey") {
            $signingKey = $State.GetAccountKey();
            $account = $State.GetAccount();
            $keyId = $(if($account -and -not $SuppressKeyId) { $account.KeyId });
        }
        else {
            $keyId = $SigningKey.KeyId;
        }

        $requestBody = New-SignedMessage -Url $Url -SigningKey $signingKey -KeyId $keyId -Nonce $nonce -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST -ErrorAction 'Continue'

        if($response.NextNonce) {
            $State.SetNonce($response.NextNonce);

            if($response.IsError -and -not $SkipRetryOnNonceError) {
                if($response.Content.Type -eq "urn:ietf:params:acme:error:badNonce") {
                    Write-Verbose "Response indicated bad nonce. Trying again with new nonce.";
                    return Invoke-SignedWebRequest -Url $Url -State $State -Payload $Payload -SuppressKeyId:$SuppressKeyId.IsPresent -SkipRetryOnNonceError;
                }
            }
        }

        if($response.IsError) {
            throw [AcmeHttpException]::new($response.ErrorMessage, $response)
        }

        return $response;
    }
}
