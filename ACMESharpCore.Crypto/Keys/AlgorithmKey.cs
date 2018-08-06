using System;
using Newtonsoft.Json;

namespace ACMESharpCore.Crypto
{
    public abstract class AlgorithmKey { 
        public abstract string TypeName { get; set; }
    }
}
