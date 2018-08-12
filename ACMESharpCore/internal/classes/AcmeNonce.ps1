class AcmeNonce {
    [ValidateNotNullOrEmpty()]
    hidden [string] $Next;

    AcmeNonce([string]$nextNonce) {
        $this.Push($nextNonce);
    }

    [void] Push([string] $nextNonce) {
        $this.Next = $nextNonce;
    }
}