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


		/**************************************** �Զ������ģ�ͺ��� ****************************************/
		// ����ģ�ͣ���������
		// atten��˥�����ӣ�attenuation��������ģ������ڴ������������ڽ��ʻ��������ض��𽥼���������
		inline half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half normalizeNormal = normalize(s.Normal),
				 normalizeLightDir = normalize(lightDir);

			half nDotL = dot(normalizeNormal, normalizeLightDir);
			half diff = nDotL;
			
			half4 colorResult;
			colorResult.rgb = (diff * atten) * s.Albedo * _LightColor0.rgb;  // ���������Ҷ�������������Ĺ�ʽ
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// ����ģ�ͣ����价��
		inline half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half normalizeNormal = normalize(s.Normal),
				 normalizeLightDir = normalize(lightDir);

			half nDotL = dot(normalizeNormal, normalizeLightDir);
			half diff = nDotL * 0.5 + 0.5;  // ʹ��һ�������ԵĹ�ʽ������ "Diffuse Wrap" ����,������Ӿ����˹�������������´α���ɢ��ĳ̶�.
			
			half4 colorResult;
			colorResult.rgb = (diff * atten) * s.Albedo * _LightColor0.rgb;  // ���������Ҷ�������������Ĺ�ʽ
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// ����ģ�ͣ�����ȫ����
		inline half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 normalizeLightDir = normalize(lightDir),
				  normalizeViewDir = normalize(viewDir),
				  normalizeNormal = normalize(s.Normal);
			
			half3 halfVector = normalize(normalizeLightDir + normalizeViewDir);
			half nDotH = max(0, dot(halfVector, normalizeNormal));
			float spec = pow(nDotH, 150);  // ��һ��ȡֵ100~200

			half4 colorResult;
			colorResult.rgb = _LightColor0.rgb * (spec * atten);
			colorResult.a = s.Alpha;

			return colorResult;
		}

		// ����ģ�ͣ����ַ�
		inline half4 LightingSimpleBlinnPhong(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half4 resultColor = LightingSimpleSpecular(s, lightDir, viewDir, atten) + 
								LightingWrapLambert(s, lightDir, atten);

			return resultColor;
		}
		/**************************************** �Զ������ģ�ͺ��� ****************************************/


		/**************************************** ����ϸ�ֺ��� ****************************************/
		// ����ϸ�֣��̶���������ϸ��
        float4 tessFixed()
        {
			return _Tess;
		}

		// ����ϸ�֣����ھ��������ϸ��
		float4 tessByDistance(appdata_full v0, appdata_full v1, appdata_full v2)
		{
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _TessMinDistance, _TessMaxDistance, _Tess);
		}

		// ����ϸ�֣����ڱ߳�������ϸ��
		float4 tessByLength(appdata_full v0, appdata_full v1, appdata_full v2)
		{
			return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _TessEdgeLength);
		}
		/**************************************** ����ϸ�ֺ��� ****************************************/


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
