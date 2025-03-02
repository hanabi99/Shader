Shader "Unlit/Kartoon"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = ""{}
        _BumpMap("BumpMap", 2D) = ""{}
        _BumpScale("BumpScale", Range(0,1)) = 1
        _RampTex("RampTex", 2D) = ""{}
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularNum("SpecularNum", Range(0,1)) = 0.5
        _OutLineColor("OutLineColor", Color) = (0,0,0,1)
        _OutLineWidth("OutLineWidth", Range(0,1)) = 0.04
    }
    SubShader
    {
        Pass
        {
            Name "OUTLINE"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex :SV_POSITION;
            };

            //��Ե����ɫ 
            fixed4 _OutLineColor;
            //��Ե�߿��
            float _OutLineWidth;

            v2f vert(appdata_base v)
            {
                v2f o;
                //���ǰѱ��濴�����Ķ��㳯���߷���ȥ������չ ��ģ�ͱ��
                v.vertex.xyz += normalize(v.normal) * _OutLineWidth;
                //��ת�����굽�ü��ռ�
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                //ֱ�ӷ��ر�Ե����ɫ �൱�ڱ����Ǵ�ɫ
                return _OutLineColor;
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            //���Լ�����Ч�� ���� ������ɫ���
            Cull Back
            //ZWrite Off
            ////�趨��ϼ���ļ��㷽ʽ
            //BlendOp ��ϲ���
            ////д��һ����Ϸ�ʽ�� ������ʽ
            //Blend Դ���� Ŀ������, Դ͸������ Ŀ��͸������
            ////д��������Ϸ�ʽ�� ʡ�Ը�ʽ
            //Blend Դ���� Ŀ������


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //���ǿ��Ե�������������float2�ĳ�Ա���ڼ�¼ ��ɫ�ͷ��������uv����
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //��ķ��� ��������߿ռ��µ�
                float3 lightDir:TEXCOORD1;
                //�ӽǵķ��� ��������߿ռ��µ�
                float3 viewDir:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
                SHADOW_COORDS(10)
            };

            float4 _MainColor; //��������ɫ
            sampler2D _MainTex; //��ɫ����
            float4 _MainTex_ST; //��ɫ��������ź�ƽ��
            sampler2D _BumpMap; //��������
            float4 _BumpMap_ST; //������������ź�ƽ��
            float _BumpScale; //��͹�̶�
            sampler2D _RampTex; //��������
            float4 _RampTex_ST; //������������ź�ƽ�ƣ����������ã�
            float4 _SpecularColor; //�߹���ɫ
            fixed _SpecularNum; //�����

            v2f vert(appdata_full v)
            {
                v2f data;
                //��ģ�Ϳռ��µĶ���ת���ü��ռ���
                data.pos = UnityObjectToClipPos(v.vertex);
                //�������������ƫ��
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                data.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                //�ڶ�����ɫ������ �õ� ģ�Ϳռ䵽���߿ռ�� ת������
                //���ߡ������ߡ�����
                //���㸱���� �����˽���� ��ֱ�����ߺͷ��ߵ����������� ͨ������ ���ߵ��е�w���Ϳ���ȷ������һ��
                float3 binormal = cross(normalize(v.tangent), normalize(v.normal)) * v.tangent.w;
                //ת������
                float3x3 rotation = float3x3(v.tangent.xyz,
                                             binormal,
                                             v.normal);
                //ģ�Ϳռ��µĹ�ķ���
                //data.lightDir = ObjSpaceLightDir(v.vertex);
                //����ģ�Ϳռ䵽���߿ռ��ת������ �Ϳ��Եõ����߿ռ��µ� ��ķ�����
                data.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                //ģ�Ϳռ��µ��ӽǵķ���
                //data.viewDir = ObjSpaceViewDir(v.vertex);
                data.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                //�õ�����ռ��µĶ�������
                data.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //��Ӱ���
                TRANSFER_SHADOW(data);

                return data;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //ͨ������������� ȡ������������ͼ���е�����
                float4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                //������ȡ�����ķ������� ���������㲢�ҿ��ܻ���н�ѹ�������㣬���յõ����߿ռ��µķ�������
                float3 tangentNormal = UnpackNormal(packedNormal);
                //���԰�͹�̶ȵ�ϵ��
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //�������������� ����ɫ����� ���ַ�����ģ�ͼ���

                //��ɫ�������������ɫ�� ����
                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _MainColor.rgb;
                //�޸�Ϊ ����������صļ��㷽ʽ
                fixed halfLambertNum = dot(normalize(tangentNormal), normalize(i.lightDir)) * 0.5 + 0.5;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                halfLambertNum += atten;

                //�������� ��������㷽ʽ
                fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * tex2D(
                    _RampTex, fixed2(halfLambertNum, halfLambertNum)).rgb;

                //�������
                float3 halfA = normalize(normalize(i.viewDir) + normalize(i.lightDir));
                //�߹ⷴ��
                //fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(tangentNormal, halfA)), _SpecularNum);
                fixed spec = dot(normalize(tangentNormal), normalize(halfA));
                //��һ����ֵ�ͼ��������бȽ� С����ֵ ȡ0 ������ֵ ȡ1
                spec = step(_SpecularNum, spec);
                //��0��1ֱ�Ӻ͸߹ⷴ����ɫ���е��� Ҫ������ɫ Ҫ��û����ɫ
                fixed3 specularColor = _SpecularColor.rgb * spec;

                //���ַ�
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + (diffuseColor + specularColor);

                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }
            Cull Back
            Blend One One
            //ZWrite Off
            ////�趨��ϼ���ļ��㷽ʽ
            //BlendOp ��ϲ���
            ////д��һ����Ϸ�ʽ�� ������ʽ
            //Blend Դ���� Ŀ������, Դ͸������ Ŀ��͸������
            ////д��������Ϸ�ʽ�� ʡ�Ը�ʽ
            //Blend Դ���� Ŀ������


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //���ǿ��Ե�������������float2�ĳ�Ա���ڼ�¼ ��ɫ�ͷ��������uv����
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //��ķ��� ��������߿ռ��µ�
                float3 lightDir:TEXCOORD1;
                //�ӽǵķ��� ��������߿ռ��µ�
                float3 viewDir:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            float4 _MainColor; //��������ɫ
            sampler2D _MainTex; //��ɫ����
            float4 _MainTex_ST; //��ɫ��������ź�ƽ��
            sampler2D _BumpMap; //��������
            float4 _BumpMap_ST; //������������ź�ƽ��
            float _BumpScale; //��͹�̶�
            sampler2D _RampTex; //��������
            float4 _RampTex_ST; //������������ź�ƽ�ƣ����������ã�
            float4 _SpecularColor; //�߹���ɫ
            fixed _SpecularNum; //�����

            v2f vert(appdata_full v)
            {
                v2f data;
                //��ģ�Ϳռ��µĶ���ת���ü��ռ���
                data.pos = UnityObjectToClipPos(v.vertex);
                //�������������ƫ��
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                data.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                //�ڶ�����ɫ������ �õ� ģ�Ϳռ䵽���߿ռ�� ת������
                //���ߡ������ߡ�����
                //���㸱���� �����˽���� ��ֱ�����ߺͷ��ߵ����������� ͨ������ ���ߵ��е�w���Ϳ���ȷ������һ��
                float3 binormal = cross(normalize(v.tangent), normalize(v.normal)) * v.tangent.w;
                //ת������
                float3x3 rotation = float3x3(v.tangent.xyz,
                                             binormal,
                                             v.normal);
                //ģ�Ϳռ��µĹ�ķ���
                //data.lightDir = ObjSpaceLightDir(v.vertex);
                //����ģ�Ϳռ䵽���߿ռ��ת������ �Ϳ��Եõ����߿ռ��µ� ��ķ�����
                data.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                //ģ�Ϳռ��µ��ӽǵķ���
                //data.viewDir = ObjSpaceViewDir(v.vertex);
                data.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                //�õ�����ռ��µĶ�������
                data.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //��Ӱ���
                TRANSFER_SHADOW(data);

                return data;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //ͨ������������� ȡ������������ͼ���е�����
                float4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                //������ȡ�����ķ������� ���������㲢�ҿ��ܻ���н�ѹ�������㣬���յõ����߿ռ��µķ�������
                float3 tangentNormal = UnpackNormal(packedNormal);
                //���԰�͹�̶ȵ�ϵ��
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //�������������� ����ɫ����� ���ַ�����ģ�ͼ���

                //��ɫ�������������ɫ�� ����
                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _MainColor.rgb;
                //�޸�Ϊ ����������صļ��㷽ʽ
                fixed halfLambertNum = dot(normalize(tangentNormal), normalize(i.lightDir)) * 0.5 + 0.5;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                halfLambertNum += atten;

                //�������� ��������㷽ʽ
                fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * tex2D(
                    _RampTex, fixed2(halfLambertNum, halfLambertNum)).rgb;

                //�������
                float3 halfA = normalize(normalize(i.viewDir) + normalize(i.lightDir));
                //�߹ⷴ��
                //fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(tangentNormal, halfA)), _SpecularNum);
                fixed spec = dot(normalize(tangentNormal), normalize(halfA));
                //��һ����ֵ�ͼ��������бȽ� С����ֵ ȡ0 ������ֵ ȡ1
                spec = step(_SpecularNum, spec);
                //��0��1ֱ�Ӻ͸߹ⷴ����ɫ���е��� Ҫ������ɫ Ҫ��û����ɫ
                fixed3 specularColor = _SpecularColor.rgb * spec;

                //���ַ�
                fixed3 color = (albedo + diffuseColor + specularColor);

                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2_f
            {
                //���㵽ƬԪ��ɫ����ӰͶ��ṹ�����ݺ�
                //����궨����һЩ��׼�ĳ�Ա����
                //��Щ������������ӰͶ��·���д��ݶ������ݵ�ƬԪ��ɫ��
                //������Ҫ�ڽṹ����ʹ��
                V2F_SHADOW_CASTER;
            };

            v2_f vert(appdata_base v)
            {
                //    ת����ӰͶ��������ƫ�ƺ�
                //    �����ڶ�����ɫ���м���ʹ�����ӰͶ������ı���
                //    ��Ҫ����
                //    2-2-1.������ռ�Ķ���λ��ת��Ϊ�ü��ռ��λ��
                //    2-2-2.���Ƿ���ƫ�ƣ��Լ�����Ӱʧ�����⣬�������ڴ�������Ӱʱ
                //    2-2-3.���ݶ����ͶӰ�ռ�λ�ã����ں�������Ӱ����
                v2_f data;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(data)
                return data;
            }

            fixed4 frag(v2_f i) : SV_Target
            {
                //��ӰͶ��ƬԪ��
                //�����ֵд�뵽��Ӱӳ��������
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}