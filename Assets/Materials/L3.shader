Shader "Custom/L3"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MyFloatTest ("FloatTest", float) = 0.0
        _MyVectorTest ("VectorTest", Vector) = (0,0,0,0)
        _My3DTest ("3DTest", 3D) = "" {}
        _MyCubeTest ("CubeTest", Cube) = ""{}
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque" 
			"ForceNoShadowCasting "="True"
		}

		LOD 10

        Pass
        {
			Name "SubShader1"

			AlphaToMask On  // Ϊ������ɫ������ alpha-to-coverage ģʽ������������������MSAAʱ�����ܷ������ã�
			Blend SrcAlpha OneMinusSrcAlpha
			Conservative True  // ���ñ��ع�դ��
			Cull Front // ���ñ����޳�

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			fixed4 _Color;

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (
                float4 vertex : POSITION, // ����λ������
                float2 uv : TEXCOORD0 // ��һ��������������
                )
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.uv = uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }

    }

    FallBack "Diffuse"
}
