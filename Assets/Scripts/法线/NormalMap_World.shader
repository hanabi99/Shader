Shader "Unlit/NormalMap_World"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //������
        _MainTex ("MainTex", 2D) = "white" { }
        //�߹ⷴ�������ɫ
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //�����
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //��������
        _BumpMap ("BumpMap", 2D) = "" { }
        //��͹�̶�
        _BumpScale ("BumpScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            //��������ź�ƫ�� x,y���� zwƫ��
            float4 _MainTex_ST;
            //������������ɫ
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularNum;
            sampler2D _BumpMap; //��������
            float4 _BumpMap_ST; //�������������ƽ��
            float _BumpScale; //��͹�̶�

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                //���ߵ�����ռ�ñ任����
                float3x3 rotation : TEXCOORD2;
            };

            v2f vert (appdata_full v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                //���߼���
                data.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                data.wpos = mul(unity_ObjectToWorld, v.vertex);
                float3 world_normal = UnityObjectToWorldNormal(v.normal.xyz);
                float3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 world_binormal = cross(normalize(world_normal), normalize(world_tangent)) * v.tangent.w;
                //���ߵ�����ռ�ñ任����
                data.rotation = float3x3(world_tangent.x, world_binormal.x, world_normal.x,
                                         world_tangent.y, world_binormal.y, world_normal.y,
                                         world_tangent.z, world_binormal.z, world_normal.z);
               return data;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
                //ȡ���������ݲ���
                float4 packNormal = tex2D(_BumpMap, i.uv.zw);
                //������
                float3 tangentNormal = UnpackNormal(packNormal);

                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //������ת��Ϊ����ռ�
                float3 worldNormal = mul(i.rotation, tangentNormal);

                //������ɫ��Ҫ�������������ɫ���
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _MainColor.rgb;
                //������
                fixed3 lambertcolor = _LightColor0.rgb * albedo.rgb * max(0, dot(worldNormal, normalize(lightDir)));
                //���
                float3 half_a = normalize(viewDir + lightDir);
                //bulin�߹� = ��Դ��ɫ * ���ʸ߹ⷴ����ɫ * pow(max(0, dot(�ӽǵ�λ����, ��ķ��䵥λ����)), �����)
                fixed3 specularcolor = _LightColor0.rgb * _SpecularColor.rgb * pow(
                    max(0, dot(worldNormal, half_a)), _SpecularNum);
                //bulinPhong
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertcolor + specularcolor;
                return fixed4(blinnPhongColor.rgb, 1);
            }
            ENDCG
        }
    }
}
