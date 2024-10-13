Shader "Unlit/Tex"
{
    Properties
    {
        //主纹理
        _MainTex ("MainTex", 2D) = "white" {}
    }
    SubShader
    {
      
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;

            v2f_img vert (appdata_base v)
            {
                v2f_img data;
                data.pos = UnityObjectToClipPos(v.vertex);
                //先缩放后平移
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
                //TRANSFORM_TEX(v.texcoord.xy, _MainTex); 相同的操作
                //v.texcoord.zw; //深度值等等
                return data;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
               fixed4 color = tex2D(_MainTex,i.uv);
               return color;
            }
            ENDCG
        }
    }
}
