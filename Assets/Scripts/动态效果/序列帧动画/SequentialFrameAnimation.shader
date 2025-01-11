Shader "Unlit/SequentialFrameAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RowCount("Row Count", Int) = 1
        _ColumnCount("Column Count", Int) = 1
        _Speed("Speed", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue"="Transparent" }

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

            float _RowCount;
            float _ColumnCount;
            float _Speed;
            sampler2D _MainTex;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //取余获取他的当前执行的帧数Index 0到64 如果speed是64那么就是1秒64帧 刚好把实例动画播完
                float frameIndex = floor(_Time.y * _Speed) % (_RowCount * _ColumnCount);
                //计算当前帧的uv偏移 (frameIndex % _ColumnCount) / _ColumnCount 的目的是 获取当前的列数 因为uv是0-1所以要获取当前坐标需要除比例
                // 1 - (floor(frameIndex / _ColumnCount) + 1) / _RowCount) 获得行数 +1的目的是因为小图uv是从左下角开始的 1- 是因为uv是从左下角开始的要偏移成左上角  / _RowCount的目的是获取当前UV比例的UV坐标
                float2 frameUV =  float2((frameIndex % _ColumnCount) / _ColumnCount , 1 - (floor(frameIndex / _ColumnCount) + 1) / _RowCount);
                //目的是渲染缩放到每个小序列帧图的比例 1/8
                float2 Size = float2(1 / _ColumnCount,1 /  _RowCount);
                //乘以比例加上偏移值
                float2 uv = i.uv * Size + frameUV;
                //最后纹理映射
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
