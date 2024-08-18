Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members a,b,c,d)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            //uint      32为无符号整形
        //int       32位整形

        //float     32位浮点数 符号:f
        //half      16位浮点数 符号:h
        //fixed     12位浮点数 

        //bool      布尔类型
        //string    字符串

        //sampler 纹理对象句柄
        //  sampler:     通用的纹理采样器，可以用于处理各种不同维度和类型的纹理
        //  sampler1D:   用于一维纹理，通常用于对一维纹理进行采样，例如从左到右的渐变色
        //  sampler2D:   用于二维纹理，最常见的纹理类型之一。它用于处理二维图像纹理，例如贴图
        //  sampler3D:   用于三维纹理，通常用于体积纹理，例如体积渲染
        //  samplerCUBE: 用于立方体纹理，通常用于处理环境映射等需要立方体贴图的情况
        //  samplerRECT: 用于处理矩形纹理，通常用于一些非标准的纹理映射需求
        //  他们都是用于处理纹理（Texture）数据的数据类型
        //  他们的主要区别是纹理的维度和类型

            int i = 1;

            float f = 1.0f;
            half h = 1.0h;
            fixed fix = 1.0;

            sampler sample;

           

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;



                
                float2 a = float2(1, 2);
                float3 b = float3(1, 2, 3);
                float4 c = float4(1, 2, 3, 4);
                float4 d = float4(2, 3, 4, 5);

                fixed3x3  m3 = fixed3x3
                (1, 2, 3,
                4, 5, 6, 
                7, 8, 9);

                bool4 boolean = c < d;
                boolean = bool3(true, true, true，true)
            };

            

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
