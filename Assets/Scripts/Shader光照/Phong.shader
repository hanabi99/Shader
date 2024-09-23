Shader "Unlit/Phong" {
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
                fixed3 color : COLOR;
                float4 vertex : SV_POSITION;
            };

            fixed3 Lembert(in float3 normal) 
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 normalWpos = UnityObjectToWorldNormal(normal);
                fixed3 color = _MainColor.rgb *  _LightColor0.rgb *  max(0,dot(lightDir,normalWpos));
                return color;
            }

            fixed3 PhongReflect(in float3 normal,in float4 vertex)
            {
              float4 vertexWpos = mul(unity_ObjectToWorld,vertex);
              float3 normalWpos = UnityObjectToWorldNormal(normal);
              float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vertexWpos);
              float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); 
              float3 reflectDir = reflect(-lightDir,normalize(normalWpos));
              fixed3 color = _LightColor0.rgb * _Specular.rgb  * pow(max(0,dot(viewDir,reflectDir)),_Glossiness);
              return color;
            }


            v2f vert(appdata_base v) 
            {
                v2f v2fdata;
                v2fdata.vertex = UnityObjectToClipPos(v.vertex);
                //Phong
                v2fdata.color = Lembert(v.normal) + PhongReflect(v.normal,v.vertex) + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return v2fdata;
            }

            fixed4 frag(v2f i) : SV_Target 
            {
               return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }
}