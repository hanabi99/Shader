Shader "Unlit/2DWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
         _Color("Color", Color) = (1,1,1,1)
        //波动幅度
        _WaveAmplitude("WaveAmplitude", Float) = 1
        //波动频率
        _WaveFrequency("WaveFrequency", Float) = 1
        //波长的倒数
        _InvWaveLength("InvWaveLength", Float) = 1
        //纹理变化速度
        _Speed("Speed", Float) = 1
    }
    SubShader
    {
         Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True" }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
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
            float4 _Color;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;
            float _Speed;
            v2f vert (appdata_base v)
            {
                v2f o;
                float4 offset;
                offset.x = sin(_Time.y * _WaveFrequency + v.vertex.z * _InvWaveLength) * _WaveAmplitude;
                offset.yzw = float3(0, 0, 0); 
                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv += frac(float2(0, _Time.y *_Speed));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
}
