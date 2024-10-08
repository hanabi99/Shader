Shader "Test/UnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MyInt("MyInt",Int) = 0
        _MyFloat("MyFloat",Float) = 0.5
        _MyColor("MyColor",Color) = (1,1,1,1)
        _MyVector("MyVector",Vector) = (0,0,0,0)
        _MyRange("MyRange",Range(0,1)) = 0.5
        _my2D("My2D",2D) = "white" {}
        _my2DArray("my2DArray", 2DArray) = ""{}
        _my3D("My3D",3D) = ""{}
        _myCube("myCube", Cube) = ""{}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue" = "Background" 
        }

        LOD 100
        ZTest Less   
        Cull Off
        ZWrite On

        UsePass "Test/UnlitShader/MYPASS"

        Pass
        {
            Name "MyPass"
            CGPROGRAM
            #pragma vertex vert // 顶点着色器 相关逻辑在vert函数中实现的
            #pragma fragment frag//声明片元着色器 相关逻辑在frag函数中实现的
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
