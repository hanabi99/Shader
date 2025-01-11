Shader "Unlit/Scroll"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpeedU ("SpeedU", Float) = 1
        _SpeedV ("SpeedV", Float) = 1
    }
    SubShader
    {
       Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue"="Transparent" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SpeedU;
            float _SpeedV;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 ScrollUV =  frac(i.uv + float2(_SpeedU * _Time.y , _SpeedV * _Time.y));
                fixed4 col = tex2D(_MainTex, ScrollUV);
                return col;
            }
            ENDCG
        }
    }
}
