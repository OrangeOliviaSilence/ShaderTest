Shader "Custom/Cut Off Test"
{
    Properties
    {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Cutout ("Cut Out", Range(0, 1)) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Cutout" 
			"Queue"="AlphaTest"
		}
        LOD 100

        Pass
        {
			Name "SubShader1Pass1"
			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			fixed4 _Color;
			half _Cutout;
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
				clip(colorResult.a - _Cutout);  // 使用Clip函数来做AlphaTest

                return colorResult;
            }
            ENDCG
        }
    }
}
