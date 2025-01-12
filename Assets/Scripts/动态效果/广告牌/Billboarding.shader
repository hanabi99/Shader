Shader "Unlit/Billboarding"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
         _Color("Color", Color) = (1,1,1,1)
        //用于控制垂直广告牌和全向广告牌的变化
        _VerticalBillboarding("VerticalBillboarding", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True" }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
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
            fixed4 _Color;
            float _VerticalBillboarding;

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 center = float3(0,0,0);
                float3 cameraInObjectPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
                float3 normal_Dir = normalize(cameraInObjectPos - center);
                //如果是垂直广告牌 则将z轴往下压至0 因为叉乘x轴能 使其y轴为(0,1,0)
                normal_Dir.y *= _VerticalBillboarding;
                //为了避免z轴和010重合 ，因为重合后再计算叉乘 可能会得到0向量
                float3 upDir = normal_Dir.y > 0.999 ? float3(1,0,0) : float3(0,1,0);
                //计算x轴
                float3 rightDir = normalize(cross(upDir, normal_Dir));
                //计算y轴
                upDir = normalize(cross(normal_Dir, rightDir));
                //计算顶点位置
                //得到顶点相对于新坐标系中心点的偏移位置
                float3 centerOffset = v.vertex.xyz - center;
                //计算顶点在新坐标系中的位置
                float3 newVertexPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normal_Dir * centerOffset.z;
                o.vertex = UnityObjectToClipPos(newVertexPos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
