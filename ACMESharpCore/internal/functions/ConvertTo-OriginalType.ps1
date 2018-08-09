function ConvertTo-OriginalType {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $inputObject,

        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [string]
        $TypeName
    )

    process {
        $result = $inputObject -as ([type]$TypeName);
        if(-not $result) {
            Write-Error "Could not convert inputObject to $TypeName";
        }

        return $result;
    }
}

