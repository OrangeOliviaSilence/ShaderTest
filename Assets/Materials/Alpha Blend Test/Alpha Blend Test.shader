Shader "Custom/Alpha Blend Test"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Transparent" 
			"Queue" = "Transparent"
			"ForceNoShadowCasting "="True"
		}

		LOD 10

        Pass
        {
			Name "SubShader1Pass1"
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (
                float4 v : POSITION, // 顶点位置输入
                float2 uv : TEXCOORD0 // 第一个纹理坐标输入
                )
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v);
                o.uv = uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 colorResult = _Color * tex2D(_MainTex, i.uv);
                return colorResult;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
