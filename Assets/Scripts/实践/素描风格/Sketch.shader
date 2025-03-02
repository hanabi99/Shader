Shader "Unlit/Sketch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        //ƽ�������ϵ��
        _TileFactor("TileFactor", Float) = 1
        //6������������ͼ
        _Sketch0("Sketch0", 2D) = ""{}
        _Sketch1("Sketch1", 2D) = ""{}
        _Sketch2("Sketch2", 2D) = ""{}
        _Sketch3("Sketch3", 2D) = ""{}
        _Sketch4("Sketch4", 2D) = ""{}
        _Sketch5("Sketch5", 2D) = ""{}
        //��Ե����ز���
        _OutLineColor("OutLineColor", Color) = (0,0,0,1)
        _OutLineWidth("OutLineWidth", Range(0,1)) = 0.04
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        UsePass "Unlit/Kartoon/OUTLINE"

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _TileFactor;
            sampler2D _Sketch0;
            sampler2D _Sketch1;
            sampler2D _Sketch2;
            sampler2D _Sketch3;
            sampler2D _Sketch4;
            sampler2D _Sketch5;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 pos : TEXCOORD1;
                fixed3 sketchWeights0:TEXCOORD2;
                //xyz�ֱ�����4��5��6�����������Ȩ��
                fixed3 sketchWeights1:TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord + _TileFactor;
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                //����ռ���շ���
                fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
                //����ռ䷨�߷���ת�� 
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed diff = max(0, dot(worldNormal, worldLightDir));
                diff = diff * 7;
                o.sketchWeights0 = fixed3(0, 0, 0);
                o.sketchWeights1 = fixed3(0, 0, 0);
                if (diff > 6)
                {
                    //��Ϊ�������Ĳ��� ���ǲ���Ҫ�ı��κ�Ȩ��
                }
                else if (diff > 5) //��һ�ź͵ڶ�����
                {
                    o.sketchWeights0.x = diff - 5;
                    o.sketchWeights0.y = 1 - o.sketchWeights0.x;
                }
                else if (diff > 4) //�ڶ��ź͵����Ų���
                {
                    o.sketchWeights0.y = diff - 4;
                    o.sketchWeights0.z = 1 - o.sketchWeights0.y;
                }
                else if (diff > 3) //�����ź͵����Ų���
                {
                    o.sketchWeights0.z = diff - 3;
                    o.sketchWeights1.x = 1 - o.sketchWeights0.z;
                }
                else if (diff > 2) //�����ź͵����Ų���
                {
                    o.sketchWeights1.x = diff - 2;
                    o.sketchWeights1.y = 1 - o.sketchWeights1.x;
                }
                else if (diff > 1) //�����ź͵����Ų���
                {
                    o.sketchWeights1.y = diff - 1;
                    o.sketchWeights1.z = 1 - o.sketchWeights1.y;
                }
                else
                {
                    o.sketchWeights1.y = diff;
                    o.sketchWeights1.z = 1 - diff;
                }
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //����ڶ�����ɫ���м���Ķ�Ӧ��������ͼƬ��Ȩ��Ϊ0 ��ô��ʱ ��Ӧ��ɫ��Ϊ(0,0,0,0)
                fixed4 sketchColor0 = tex2D(_Sketch0, i.uv) * i.sketchWeights0.x;
                fixed4 sketchColor1 = tex2D(_Sketch1, i.uv) * i.sketchWeights0.y;
                fixed4 sketchColor2 = tex2D(_Sketch2, i.uv) * i.sketchWeights0.z;
                fixed4 sketchColor3 = tex2D(_Sketch3, i.uv) * i.sketchWeights1.x;
                fixed4 sketchColor4 = tex2D(_Sketch4, i.uv) * i.sketchWeights1.y;
                fixed4 sketchColor5 = tex2D(_Sketch5, i.uv) * i.sketchWeights1.z;
                fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.sketchWeights0.x - i.sketchWeights0.y - i.sketchWeights0
                    .z - i.sketchWeights1.x - i.sketchWeights1.y - i.sketchWeights1.z);
                fixed4 sketchColor = sketchColor0 + sketchColor1 + sketchColor2 + sketchColor3 + sketchColor4 +
                    sketchColor5 + whiteColor;
                UNITY_LIGHT_ATTENUATION(atten, i, i.pos);
                return fixed4(sketchColor.rgb * atten * _Color.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}