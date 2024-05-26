Shader "Custom/L2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
        _RimPower ("Rim Power", Range(0, 1)) = 0.5
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
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
		}

		LOD 20

		CGPROGRAM
		#pragma surface surf Lambert fullforwardshadows
		#pragma target 2.5

		fixed4 _Color;
		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
		}

		ENDCG

	}
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque" 
			"ForceNoShadowCasting "="True"
		}
        LOD 20
		
		Stencil
		{
			Ref 2
			Comp Greater
			Pass Invert
		}  

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		fixed4 _RimColor;
		half _RimPower;
        sampler2D _MainTex;
		sampler2D _NormalMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
			float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

			// 法线贴图
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap)).rgb;

			// 边缘高亮
			half rimAngle = 1 - saturate( dot (normalize(IN.viewDir), o.Normal) );
			o.Emission = _RimColor.rgb * rimAngle * _RimPower;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
	SubShader
	{
		AlphaToMask On  // 为此子着色器启用 alpha-to-coverage 模式（仅当相机组件启用了MSAA时，才能发挥作用）
		Blend SrcAlpha OneMinusSrcAlpha
		Conservative True  // 启用保守光栅化
		Cull Back // 启用背面剔除
		ZClip True
		ZTest Greater

		UsePass "Custom/L3/SubShader1"
	}
  //  SubShader
  //  {
  //      Tags 
		//{ 
		//	"RenderType"="Opaque" 
		//	"ForceNoShadowCasting "="True"
		//}

		//LOD 10

  //      Pass
  //      {
		//	Name "SubShader1"


  //          CGPROGRAM
  //          #pragma vertex vert
  //          #pragma fragment frag

		//	fixed4 _Color;

  //          struct v2f {
  //              float2 uv : TEXCOORD0;
  //              float4 pos : SV_POSITION;
  //          };

  //          v2f vert (
  //              float4 vertex : POSITION, // 顶点位置输入
  //              float2 uv : TEXCOORD0 // 第一个纹理坐标输入
  //              )
  //          {
  //              v2f o;
  //              o.pos = UnityObjectToClipPos(vertex);
  //              o.uv = uv;
  //              return o;
  //          }

  //          fixed4 frag (v2f i) : SV_Target
  //          {
  //              return _Color;
  //          }
  //          ENDCG
  //      }
  //  }

    FallBack "Diffuse"
}
