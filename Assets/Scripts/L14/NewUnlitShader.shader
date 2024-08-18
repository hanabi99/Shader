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
            //uint      32Ϊ�޷�������
        //int       32λ����

        //float     32λ������ ����:f
        //half      16λ������ ����:h
        //fixed     12λ������ 

        //bool      ��������
        //string    �ַ���

        //sampler ���������
        //  sampler:     ͨ�õ�������������������ڴ�����ֲ�ͬά�Ⱥ����͵�����
        //  sampler1D:   ����һά����ͨ�����ڶ�һά������в�������������ҵĽ���ɫ
        //  sampler2D:   ���ڶ�ά�����������������֮һ�������ڴ����άͼ������������ͼ
        //  sampler3D:   ������ά����ͨ����������������������Ⱦ
        //  samplerCUBE: ��������������ͨ�����ڴ�����ӳ�����Ҫ��������ͼ�����
        //  samplerRECT: ���ڴ����������ͨ������һЩ�Ǳ�׼������ӳ������
        //  ���Ƕ������ڴ�������Texture�����ݵ���������
        //  ���ǵ���Ҫ�����������ά�Ⱥ�����

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
                boolean = bool3(true, true, true��true)
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
