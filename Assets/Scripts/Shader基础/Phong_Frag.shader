Shader "Unlit/Phong_Frag" {
    Properties {
        //材质颜色
        _MainColor ("MainColor", Color) = (1, 1, 1, 1)
        //高光反射材质颜色
        _Specular ("_Specular", Color) = (1, 1, 1, 1)
        //光泽度
        _Glossiness ("_Glossiness", Range(0, 20)) = 0.5
    }
    SubShader {
        Tags { "LightMode" = "ForwardBase" }
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _Specular;
            float _Glossiness;

            struct v2f {
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD0;
            };

            fixed3 Lembert(in float3 normalWpos) 
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //float3 normalWpos = UnityObjectToWorldNormal(normal);
                fixed3 color = _MainColor.rgb *  _LightColor0.rgb *  max(0,dot(lightDir,normalWpos));
                return color;
            }

            fixed3 PhongReflect(in float3 normalWpos,in float3 vertexWpos)
            {
              //float4 vertexWpos = mul(unity_ObjectToWorld,vertex);
              //float3 normalWpos = UnityObjectToWorldNormal(normal);
              float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vertexWpos);
              float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
              float3 reflectDir = reflect(-lightDir,normalWpos);
              fixed3 color = _LightColor0.rgb * _Specular.rgb  * pow(max(0,dot(viewDir,reflectDir)),_Glossiness);
              return color;
            }


            v2f vert(appdata_base v) 
            {
                v2f v2fdata;
                v2fdata.wPos = mul(UNITY_MATRIX_M,v.vertex);
                v2fdata.vertex = UnityObjectToClipPos(v.vertex);
                v2fdata.normal = UnityObjectToWorldNormal(v.normal);
                return v2fdata;
            }

            fixed4 frag(v2f i) : SV_Target 
            {
              fixed3 color = Lembert(i.normal) + PhongReflect(i.normal,i.wPos) + UNITY_LIGHTMODEL_AMBIENT.rgb;
              return fixed4(color,1);
            }
            ENDCG
        }
    }
}