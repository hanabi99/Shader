Shader "Unlit/GaoSi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurInterval("BlurSize", Range(0, 10)) = 1
    }
    SubShader
    {
        //用于包裹共用代码 在之后的多个Pass当中都可以使用的代码
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        //纹素 x=1/宽  y=1/高
        half4 _MainTex_TexelSize;
        float _BlurInterval;

        struct v2f
        {
            //5个像素的uv坐标偏移
            half2 uv[5] : TEXCOORD0;
            //顶点在裁剪空间下坐标
            float4 vertex : SV_POSITION;
        };

        //片元着色器函数
        //两个Pass可以使用同一个 我们把里面的逻辑写的通用即可
        fixed4 fragBlur(v2f i):SV_Target
        {
            //卷积运算
            //卷积核 其中的三个数 因为只有这三个数 没有必要声明为5个单位的卷积核
            float weight[3] = {0.4026, 0.2442, 0.0545};
            //先计算当前像素点
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            //去计算左右偏移1个单位的 和 左右偏移两个单位的 对位相乘 累加
            for (int it = 1; it < 3; it++)
            {
                //要和右元素相乘
                sum += tex2D(_MainTex, i.uv[it*2 - 1]).rgb * weight[it];
                //和左元素相乘
                sum += tex2D(_MainTex, i.uv[it*2]).rgb * weight[it];
            }

            return fixed4(sum, 1);
        }

        ENDCG

        Tags { "RenderType"="Opaque" }

        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            Name "GAUSSIAN_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            //水平方向的 顶点着色器函数
            v2f vertBlurHorizontal(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //5个像素的uv偏移
                half2 uv = v.texcoord;

                //去进行5个像素 水平位置的偏移获取
                o.uv[0] = uv;
                o.uv[1] = uv + half2(_MainTex_TexelSize.x*1, 0) * _BlurInterval;
                o.uv[2] = uv - half2(_MainTex_TexelSize.x*1, 0) * _BlurInterval;
                o.uv[3] = uv + half2(_MainTex_TexelSize.x*2, 0) * _BlurInterval;
                o.uv[4] = uv - half2(_MainTex_TexelSize.x*2, 0) * _BlurInterval;

                return o;
            }
            ENDCG
        }

        Pass
        {
            Name "GAUSSIAN_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            //竖直方向的 顶点着色器函数
            v2f vertBlurVertical(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //5个像素的uv偏移
                half2 uv = v.texcoord;

                //去进行5个像素 竖直位置的偏移获取
                o.uv[0] = uv;
                o.uv[1] = uv + half2(0, _MainTex_TexelSize.y*1) * _BlurInterval;
                o.uv[2] = uv - half2(0, _MainTex_TexelSize.y*1) * _BlurInterval;
                o.uv[3] = uv + half2(0, _MainTex_TexelSize.y*2) * _BlurInterval;
                o.uv[4] = uv - half2(0, _MainTex_TexelSize.y*2) * _BlurInterval;

                return o;
            }
            ENDCG
        }
    }

    Fallback Off
}
