Shader "Unlit/TransParentBoth"
{
     Properties {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //������
        _MainTex ("MainTex", 2D) = "white" { }
        //�߹ⷴ�������ɫ
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //�����
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //͸����
        AplhaScale("AplhaScale", Range(0,1)) = 1
    }

    //����������BuilnPhong����ģ��
    SubShader {
         Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparept"}
        Pass {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
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
            float _SpecularNum;
            fixed AplhaScale;


            struct v2f {
                float4 pos : SV_POSITION;
                half2  uv : TEXCOORD0;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD1;
            };
         
            fixed3 getLambertFColor(in float3 wNormal,fixed3 NewMainColor)
            {
                //�õ���Դ��λ����
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //������������ع��յ���������ɫ
                fixed3 color = _LightColor0.rgb * NewMainColor.rgb * max(0, dot(wNormal, lightDir));

                return color;
            }

            
            fixed3 getSpecularColor(in float3 wPos, in float3 wNormal)
            {
                //1.�ӽǵ�λ����
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );

                //2.��ķ��䵥λ����
                //��ķ���
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //��Ƿ�������
                float3 halfA = normalize(viewDir + lightDir);
                
                //color = ��Դ��ɫ * ���ʸ߹ⷴ����ɫ * pow( max(0, dot(�ӽǵ�λ����, ��ķ��䵥λ����)), ����� )
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(wNormal, halfA)), _SpecularNum );

                return color;
            }

            v2f vert(appdata_base v) {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                //�����ź�ƽ��
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //TRANSFORM_TEX(v.texcoord.xy, _MainTex); ��ͬ�Ĳ���
                //v.texcoord.zw; //���ֵ�ȵ�
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                //����ת������ռ�
                data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return data;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //������ɫ��Ҫ�������������ɫ���
                fixed3 albedo = texColor.rgb * _MainColor;
                //���������ع�����ɫ
                fixed3 lambertColor = getLambertFColor(i.wNormal,albedo);
                //����BlinnPhongʽ�߹ⷴ����ɫ
                fixed3 specularColor = getSpecularColor(i.wPos, i.wNormal);
                //������������ɫ = ��������ɫ * albedo + �����ع���ģ��������ɫ + Phongʽ�߹ⷴ�����ģ��������ɫ
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertColor + specularColor; 

                return fixed4(blinnPhongColor.rgb, texColor.a * AplhaScale);
            }
               ENDCG
        }
        Pass {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
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
            float _SpecularNum;
            fixed AplhaScale;


            struct v2f {
                float4 pos : SV_POSITION;
                half2  uv : TEXCOORD0;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD1;
            };
         
            fixed3 getLambertFColor(in float3 wNormal,fixed3 NewMainColor)
            {
                //�õ���Դ��λ����
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //������������ع��յ���������ɫ
                fixed3 color = _LightColor0.rgb * NewMainColor.rgb * max(0, dot(wNormal, lightDir));

                return color;
            }

            
            fixed3 getSpecularColor(in float3 wPos, in float3 wNormal)
            {
                //1.�ӽǵ�λ����
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );

                //2.��ķ��䵥λ����
                //��ķ���
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //��Ƿ�������
                float3 halfA = normalize(viewDir + lightDir);
                
                //color = ��Դ��ɫ * ���ʸ߹ⷴ����ɫ * pow( max(0, dot(�ӽǵ�λ����, ��ķ��䵥λ����)), ����� )
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(wNormal, halfA)), _SpecularNum );

                return color;
            }

            v2f vert(appdata_base v) {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                //�����ź�ƽ��
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //TRANSFORM_TEX(v.texcoord.xy, _MainTex); ��ͬ�Ĳ���
                //v.texcoord.zw; //���ֵ�ȵ�
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                //����ת������ռ�
                data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return data;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //������ɫ��Ҫ�������������ɫ���
                fixed3 albedo = texColor.rgb * _MainColor;
                //���������ع�����ɫ
                fixed3 lambertColor = getLambertFColor(i.wNormal,albedo);
                //����BlinnPhongʽ�߹ⷴ����ɫ
                fixed3 specularColor = getSpecularColor(i.wPos, i.wNormal);
                //������������ɫ = ��������ɫ * albedo + �����ع���ģ��������ɫ + Phongʽ�߹ⷴ�����ģ��������ɫ
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertColor + specularColor; 

                return fixed4(blinnPhongColor.rgb, texColor.a * AplhaScale);
            }
                ENDCG
}
   }
}

