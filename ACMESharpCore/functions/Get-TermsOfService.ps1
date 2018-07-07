function Get-TermsOfService {
    <#
        .SYNOPSIS
        Reads the TOS from the ACME-Server

        .DESCRIPTION
        Reads the TOS from the given ACME-Server
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $ACMEStoreDir = ".",

        [Switch]
        $ShowTOS
    )

    process {
        $serviceDirectory = Get-ServiceDirectory -ACMEStorePath $ACMEStoreDir;

        #TODO: Make this independent of PDF
        Invoke-WebRequest $serviceDirectory.Meta.TermsOfService -OutFile "$ACMEStoreDir/TOS.pdf";

        if($ShowTOS) {
            Start-Process "$ACMEStoreDir/TOS.pdf";
        }
    }
}