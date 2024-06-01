Shader "Custom/Soldier_L1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Tess ("Tessellation Count", Range(1,32)) = 4
		_TessMinDistance ("Tessellation Min Distance", Float) = 1
		_TessMaxDistance ("Tessellation Max Distance", Float) = 10
		_TessEdgeLength ("Tessellation Edge length", Range(2,50)) = 15
		_TessPhong ("Tessellation Phong Strengh", Range(0,1)) = 0.5
		_WaveFreq ("Wave Freq", Range(0,2)) = 1
    }
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque" 
			"Queue" = "Geometry+1"
			"LightMode" = "Always"
		}

		LOD 200

		CGPROGRAM
		#pragma target 2.5
		#pragma surface surf Lambert fullforwardshadows tessellate:tessFixed tessphong:_TessPhong vertex:vert
		#pragma enable_d3d11_debug_symbols
		#include "Tessellation.cginc"
		#define PI 3.14159265359

		fixed4 _Color;
		sampler2D _MainTex;
		float _Tess;
		float _TessMinDistance;
		float _TessMaxDistance;
		float _TessEdgeLength;
		float _TessPhong;
		half _WaveFreq;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v)
		{
			v.vertex.z += sin(_Time.y * 2 * PI * _WaveFreq) * (1 - v.texcoord.x);
		}


		/**************************************** 自定义光照模型函数 ****************************************/
		// 光照模型：基础漫射
		// atten是衰减因子（attenuation），用于模拟光线在传播过程中由于介质或距离等因素而逐渐减弱的现象
		inline half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half normalizeNormal = normalize(s.Normal),
				 normalizeLightDir = normalize(lightDir);

			half nDotL = dot(normalizeNormal, normalizeLightDir);
			half diff = nDotL;
			
			half4 colorResult;
			colorResult.rgb = (diff * atten) * s.Albedo * _LightColor0.rgb;  // 兰伯特余弦定理计算漫反射光的公式
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// 光照模型：漫射环绕
		inline half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half normalizeNormal = normalize(s.Normal),
				 normalizeLightDir = normalize(lightDir);

			half nDotL = dot(normalizeNormal, normalizeLightDir);
			half diff = nDotL * 0.5 + 0.5;  // 使用一个经验性的公式来计算 "Diffuse Wrap" 因子,这个因子决定了光线在物体表面下次表面散射的程度.
			
			half4 colorResult;
			colorResult.rgb = (diff * atten) * s.Albedo * _LightColor0.rgb;  // 兰伯特余弦定理计算漫反射光的公式
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// 光照模型：基础全反射
		inline half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 normalizeLightDir = normalize(lightDir),
				  normalizeViewDir = normalize(viewDir),
				  normalizeNormal = normalize(s.Normal);
			
			half3 halfVector = normalize(normalizeLightDir + normalizeViewDir);
			half nDotH = max(0, dot(halfVector, normalizeNormal));
			float spec = pow(nDotH, 150);  // 幂一般取值100~200

			half4 colorResult;
			colorResult.rgb = _LightColor0.rgb * (spec * atten);
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// 光照模型：布林冯
		inline half4 LightingSimpleBlinnPhong(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half4 resultColor = LightingSimpleSpecular(s, lightDir, viewDir, atten) + 
								LightingWrapLambert(s, lightDir, atten);

			return resultColor;
		}
		/**************************************** 自定义光照模型函数 ****************************************/


		/**************************************** 曲面细分函数 ****************************************/
		// 曲面细分：固定量的曲面细分
        float4 tessFixed()
        {
			return _Tess;
		}

		// 曲面细分：基于距离的曲面细分
		float4 tessByDistance(appdata_full v0, appdata_full v1, appdata_full v2)
		{
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _TessMinDistance, _TessMaxDistance, _Tess);
		}

		// 曲面细分：基于边长的曲面细分
		float4 tessByLength(appdata_full v0, appdata_full v1, appdata_full v2)
		{
			return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _TessEdgeLength);
		}
		/**************************************** 曲面细分函数 ****************************************/


		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 colorResult = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = colorResult.rgb;
			o.Alpha = colorResult.a;
		}

		ENDCG

	}

    FallBack "Diffuse"
}
