Shader "Unlit/PageTurn"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackTex("BackTex", 2D) = ""{}
        _WaveLen("WaveLegth", Range(0,3)) = 0
        _WeightX("WeightX", Range(0,1)) = 0
        _WeightY("WeightY", Range(0,1)) = 0
        _AngleProgress("AngleProgress", Range(0,180)) = 0
        _MoveDis("MoveDis", Float) = 0

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            //��������
            sampler2D _MainTex;
            //��������
            sampler2D _BackTex;
            //��ҳ���� 0~180�ȵĽǶ�
            float _AngleProgress;
            //x������Ȩ��
            fixed _WeightX;
            //Y������Ȩ��
            fixed _WeightY;
            //����
            float _WaveLen;
            //ƽ�ƾ���
            float _MoveDis;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                //cos sin
                float c;
                float s;
                sincos(radians(_AngleProgress), s, c);
                //Z����ת����
                float4x4 rotateMat = float4x4(c, -s, 0, 0,
                                              s, c, 0, 0,
                                              0, 0, 1, 0,
                                              0, 0, 0, 1);
                //��ƽ������ת
                v.vertex = v.vertex + float4(_MoveDis, 0, 0, 0);

                //�������
                float waveWeight = 1 - (abs(90 - _AngleProgress) / 90);
                v.vertex.y += sin(v.vertex.x * _WaveLen) * waveWeight * _WeightY;
                //X������
                v.vertex.x -= v.vertex.x * waveWeight * _WeightX;
                //����Ƕ�
                float4 pos = mul(rotateMat, v.vertex);
                pos -= float4(_MoveDis, 0, 0, 0);
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i, fixed face: VFACE) : SV_Target
            {
                fixed4 col = face > 0 ? tex2D(_MainTex, i.uv) : tex2D(_BackTex, i.uv);
                // sample the texture
                return col;
            }
            ENDCG
        }
    }
}