Shader "Unlit/ShaderPT"
{
    Properties
    {
        //棋盘格行列数
        _TileCount("TileCount", Float) = 8
        //格子颜色1
        _Color1("Color1", Color) = (1,1,1,1)
        //格子颜色2
        _Color2("Color2", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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

            float _TileCount;
            float4 _Color1;
            float4 _Color2;


            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //把uv坐标从0~1范围 缩放到 0~_TileCount
                float2 uv = i.uv * _TileCount;
                //相当于就是得到当前 uv坐标 所在的格子索引位置
                float2 posIndex = floor(uv);
                // posIndex.x + posIndex.y 
                //  情况1：如果它们同奇或者同偶 加起来就是偶数
                //  情况2：如果不同一个奇数，一个偶数，加起来就是奇数
                //  这的结果只会是 0或者1 如果是0 代表满足情况1;如果是1 代表满足情况2
                float value = (posIndex.x + posIndex.y ) % 2;
                //因为value只会是0或1 ，那么我们完全可以利用lerp进行取值
                //取的就是两端的极限值 只有两种情况
                return lerp(_Color1, _Color2, value);
            }
            ENDCG
        }
    }
}
