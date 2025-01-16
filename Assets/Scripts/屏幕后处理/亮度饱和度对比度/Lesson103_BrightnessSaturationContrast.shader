Shader "Unlit/Lesson103_BrightnessSaturationContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //���ȱ���
        _Brightness("Brightness", Float) = 1
        //���Ͷȱ���
        _Saturation("Saturation", Float) = 1
        //�Աȶȱ���
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

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
            half _Brightness;
            half _Saturation;
            half _Contrast;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�Ӳ�����������в��� 
                fixed4 renderTexColor = tex2D(_MainTex, i.uv);

                //���ȼ���
                fixed3 finalColor = renderTexColor.rgb * _Brightness;

                //���Ͷȼ���
                fixed L = 0.2126*finalColor.r + 0.7152*finalColor.g + 0.0722*finalColor.b;
                fixed3 LColor = fixed3(L,L,L);
                finalColor = lerp(LColor, finalColor, _Saturation);

                //�Աȶȼ���
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback off
}
