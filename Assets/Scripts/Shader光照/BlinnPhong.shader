Shader "Unlit/BlinnPhong"
{
    Properties
    {
        //材质的漫反射光照颜色
        _MainColor("MainColor", Color) = (1,1,1,1)
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularNum("SpecularNum", Range(0, 20)) = 0.5
    }
    SubShader
    {
        Pass
        {
            //设置我们的光照模式 ForwardBase这种向前渲染模式 主要是用来处理 不透明物体的 光照渲染的
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //引用对应的内置文件 
            //主要是为了之后 的 比如内置结构体使用，内置变量使用
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //材质的漫反射颜色
            fixed4 _MainColor;
            //对应属性当中的颜色和光泽度
            fixed4 _SpecularColor;
            float _SpecularNum;

            //顶点着色器传递给片元着色器的内容
            struct v2f
            {
                //裁剪空间下的顶点坐标信息
                float4 pos:SV_POSITION;
                //对应顶点的漫反射光照颜色
                fixed3 color:COLOR;
            };

            //计算兰伯特光照模型 颜色 相关函数
            fixed3 getLambertColor(in float3 objNormal)
            {
       
                float3 normal = UnityObjectToWorldNormal(objNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(normal, lightDir));

                return color;
            }

            //计算BlinnPhong高光反射光照模型 颜色 相关函数
            fixed3 getSpecularColor(in float4 objVertex, in float3 objNormal)
            {
      
                float3 worldPos = mul(UNITY_MATRIX_M, objVertex);
          
                float3 viewDir = _WorldSpaceCameraPos.xyz - worldPos;
         
                viewDir = normalize(viewDir);

        
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
       
                float3 normal = UnityObjectToWorldNormal(objNormal);
     
                float3 halfA = normalize(viewDir + lightDir);

                //高光反射光照颜色 = 光源的颜色 * 材质高光反射颜色 * max（0, 标准化后观察方向向量· 标准化后的反射方向）幂
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(normal, halfA)), _SpecularNum);

                return color;
            }
          

            v2f vert (appdata_base v)
            {
                v2f v2fData;
                //把模型空间下的 顶点转换到裁剪空间下
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                //计算兰伯特光照模型所得颜色
                fixed3 lambertColor = getLambertColor(v.normal);
                //计算BlinnPhong式高光反射光照模型所得颜色
                fixed3 specularColor = getSpecularColor(v.vertex, v.normal);
                //物体表面光照颜色 = 环境光颜色 + 兰伯特光照模型所得颜色 + Phong式高光反射光照模型所得颜色
                v2fData.color = UNITY_LIGHTMODEL_AMBIENT.rgb + lambertColor + specularColor;

                return v2fData;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }
}
