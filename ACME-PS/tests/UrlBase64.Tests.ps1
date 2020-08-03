InModuleScope ACME-PS {
    Context 'ConvertTo-Base64Url and ConvertFrom-Base64 url are roundtrippable' {
        $value = [byte[]]@(131,251,190,1);

        $base64Form = ConvertTo-UrlBase64 -InputBytes $value;
        It 'Converted the input successfully' {
            $base64Form | Should -Be "g_u-AQ";
        }

        $roundtripped = ConvertFrom-UrlBase64 $base64Form;
        It 'Should match the orginial array' {
            $roundtripped | Should -Be $value;
        }
    }
}