Shader "Unlit/Edge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //边缘颜色
        _EdgeColor ("Edge Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            //Unity内置纹素变量
            half4 _MainTex_TexelSize;
            fixed4 _EdgeColor;


            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                return o;
            }

            fixed4 gety_l_color(fixed4 color)
            {
                return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
            }

            half Sobel(v2f o)
            {
                //Sobel算子对应的两个卷积核
                half Gx[9] = {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };
                half Gy[9] = {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                fixed edgeX = 0;
                fixed edgeY = 0;
                for (int a = 0; a < 9; a++)
                {
                    edgeX += gety_l_color(tex2D(_MainTex, o.uv[a]).rgba) * Gx[a];
                    edgeY += gety_l_color(tex2D(_MainTex, o.uv[a]).rgba) * Gy[a];
                }
                return edgeX + edgeY;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv[4]);
                fixed G = Sobel(i);
                fixed4 color = lerp(col , _EdgeColor, G);
                return color;
            }
            ENDCG
        }
    }
}