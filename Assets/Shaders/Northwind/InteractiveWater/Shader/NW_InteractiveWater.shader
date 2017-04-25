Shader "Northwind/Interactive Water" {
	Properties {
		//Main
		_OverlayTex("Overlay", 2D) = "clear" {}
		_OverlayTexDistortStrength("Overlay Texture Distort Strength", Range(0,1)) = 0.025
		_OverlayTexDistortSpeed("Overlay Texture Distort Speed", Float) = 1
		_TintColor ("Tint Color", Color) = (0.345, 0.675, 1, 0)
		_Transparency("Transparancy", Range(0,1)) = 0

		[Normal]
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Glossiness ("Glossiness", Range(0,1)) = 0.9

		//Wind
		_WindSpeed ("Wind Speed", float) = 0.25
		_WindStrength ("Wind Strength", float) = 0.075
		_WindScale ("Wind Scale", float) = 0.5

		//Ripples
		_RippleRefractionStrength ("Ripple Refraction Strength", Range(0,1)) = 0.05
		_RippleReflectionStrength ("Ripple Reflection Strength", Range(0,1)) = 1
		_RippleFrequency("Ripple Frequency", Range(0,10)) = 3
		_RippleSpeed ("Ripple Speed", Float) = 6
		_RippleDuration("Ripple Duration", Float) = 2

		//Foam
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_FoamTextureOverlay("Foam Texture Overlay", 2D) = "white" {}
		_FoamTextureDistortStrength("Foam Texture Distort Strength", Range(0,1)) = 0.025
		_FoamTextureDistortSpeed("Foam Texture Distort Speed", Float) = 1

		_UseRippleFoam("Use Ripple Foam", Int) = 1
		_RippleFoamCut("Ripple Foam Cut", Range(0,1)) = 0.001
		_RippleFoamStitches("Ripple Foam Stitches", Range(0,1)) = 0.2
		_RippleFoamNoiseSpeed("Ripple Foam Noise Speed", Float) = 1

		_RippleFoamFrequency("Ripple Foam Frequency", Range(0,10)) = 1
		_RippleFoamSpeed("Ripple Foam Speed", Float) = 6
		_RippleFoamDuration("Ripple Foam Duration", Float) = 2

		_UseEdgeFoam("Use Edge Foam", Int) = 1
		_EdgeFoamCut("Background Foam Cut", Range(0,1)) = 0.65
		_EdgeFoamStitches("Edge Foam Stitches", Range(0,1)) = 0.1
		_EdgeFoamNoiseSpeed("Edge Foam Noise Speed", Float) = 1
		
		//Blur
		_UnderWaterBlur("Underwater Blur", Range(0,30)) = 10
		_BlurIterations("Blur Iterations", Range(1,10)) = 3

		//Emission
		_EmissionIntensity("Emission Intensity", Range(0,1)) = 1
		_EmissionCut("Emission Cut", Range(0,1)) = 1

		//Reflection
		_SSR_Transparency("Transparency", Range(0,1)) = 0.75

		_SSR_Noise("SSR Noise", Range(0,1)) = 0.05
		_SSR_Iterations("SSR Iterations", Range(1, 400)) = 50
		_SSR_StepSize("SSR Step Size", Float) = 0.2

		_SSR_FadeDistance("SSR Fade Distance", Float) = 500
		_SSR_FadeSteps("SSR Fade Steps", Range(1, 400)) = 10

		_SSR_DebugDepth("SSR Debug Depth", Int) = 0

		//Shock
		_ShockTex("Shock Texture", 2D) = "white" {}
		_ShockTextureSpeed("Shock Texture Speed", 2D) = "black" {}
		_ShockTexScale("Shock Texture Scale", Float) = 1

		_ShockBasicBrightness("Shock Basic Brightness", Float) = 2
		_ShockSpeed("Shock Speed", Float) = 1
		_ShockDuration("Shock Duration", Float) = 4

		_ShockBrightnessColor("Shock Brightness Color", Color) = (0,0,1,1)
		_ShockBrightness("Shock Brightness", Float) = 8
		_ShockEmissionDuration("Shock Emission Duration", Float) = 4
		_ShockEmissionDelay("Shock Emission Delay", Float) = 1

		//Editor
		_E_ToggleMain("Toggle Main", Int) = 1
		_E_ToggleWind("Toggle Wind", Int) = 1
		_E_ToggleRipples("Toggle Ripples", Int) = 1
		_E_ToggleFoam("Toggle Foam", Int) = 1
		_E_ToggleBlur("Toggle Blur", Int) = 1
		_E_ToggleEmission("Toggle Emission", Int) = 1
		_E_ToggleReflection("Toggle Reflection", Int) = 1
		_E_ToggleShock("Toggle Shock", Int) = 1
	}
	SubShader {
		Tags{ "RenderType"="Transparent" "Queue"="Transparent"   "ForceNoShadowCasting" = "True"}

		ZWrite Off ZTest LEqual

		GrabPass {}
		
		CGPROGRAM
		#pragma surface surf Standard alpha:auto fullforwardshadows vertex:vert
		#pragma target 3.0

		#define PI    3.14159265

		#include "../../Libs/noiseSimplex.cginc"
		#include "../../Libs/blur.cginc"
		#include "../../Libs/ssr.cginc"

		struct Input {
			//Main
			float2 uv_OverlayTex;
			float2 uv_NormalMap;
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal; 

			//Grab
			float4 grabPos : TEXCOORD1;

			//Foam
			float4 vertexColor : COLOR;
			INTERNAL_DATA
		};

		//Main values
		sampler2D _OverlayTex;
		float _OverlayTexDistortStrength;
		float _OverlayTexDistortSpeed;
		float4 _TintColor;
		float _Transparency;

		sampler2D _NormalMap;
		half _Glossiness;

		//Wind
		float _WindSpeed;
		float _WindStrength;
		float _WindScale;

		//Ripples
		float _RippleRefractionStrength;
		float _RippleReflectionStrength;
		float _RippleFrequency;
		float _RippleSpeed;
		float _RippleDuration;

		//Foam
		float4 _FoamColor;
		sampler2D _FoamTextureOverlay;
		float _FoamTextureDistortStrength;
		float _FoamTextureDistortSpeed;

		int _UseRippleFoam;
		float _RippleFoamCut;
		float _RippleFoamStitches;
		float _RippleFoamNoiseSpeed;

		float _RippleFoamFrequency;
		float _RippleFoamSpeed;
		float _RippleFoamDuration;

		int _UseEdgeFoam;
		float _EdgeFoamCut;
		float _EdgeFoamStitches;
		float _EdgeFoamNoiseSpeed;

		//Blur
		float _UnderWaterBlur;
		int _BlurIterations;

		//Emission
		float _EmissionIntensity;
		float _EmissionCut;

		//Reflection
		float _SSR_Transparency;
		float _SSR_Noise;
		float _SSR_Iterations;
		float _SSR_StepSize;

		float _SSR_FadeDistance;
		float _SSR_FadeSteps;

		int _SSR_DebugDepth;

		//Shock
		sampler2D _ShockTex;
		sampler2D _ShockTextureSpeed;

		float _ShockTexSpeed;
		float _ShockTexScale;
		
		float _ShockBasicBrightness;
		float _ShockSpeed;
		float _ShockDuration;

		float4 _ShockBrightnessColor;
		float _ShockBrightness;
		float _ShockEmissionDuration;
		float _ShockEmissionDelay;

		//Editor values
		int _E_ToggleMain;
		int _E_ToggleWind;
		int _E_ToggleRipples;
		int _E_ToggleFoam;
		int _E_ToggleBlur;
		int _E_ToggleEmission;
		int _E_ToggleReflection;
		int _E_ToggleShock;

		/////////////////
		//Backend
		//Grab values
		sampler2D _GrabTexture;
		sampler2D _LastCameraDepthTexture;

		//Hit values
		float4 _WaterRipplePositions[50];
		int _WaterRippleCount;

		//Shock values
		float4 _WaterShockPosition;

		float VertexWind(float4 worldPos) {
			float lHeight = snoise(worldPos.xyz * _WindScale + float3(_Time.y, 0, _Time.x) * _WindSpeed);
			lHeight += snoise(worldPos.zyx * _WindScale + float3(_Time.x, 0, -_Time.y) * _WindSpeed);

			return lHeight * _WindStrength;
		}

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			//Main Inputs
			o.vertexColor = v.color;

			//Wind Effect
			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
			worldPos.y += VertexWind(worldPos);

			//Back to Object Space
			v.vertex = mul(unity_WorldToObject, worldPos);

			//Final Inputs
			float4 lClipPos = UnityObjectToClipPos(v.vertex);
			o.grabPos = ComputeGrabScreenPos(lClipPos);
		}

		float rand(float3 co)
		{
			return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//Ripple Values
			float4 lRippleDir = float4(0, 0, 0, 0);
			float4 lRippleHeight = float4(0, 0, 0, 0);
			float4 lRippleHeightSave = float4(0, 0, 0, 0);

			int matched = 0;

			for (int p = 0; p < _WaterRippleCount; p++) {
				float lDistance = distance(IN.worldPos.xyz, _WaterRipplePositions[p].xyz) * 4;
				float lTime = _Time.y - _WaterRipplePositions[p].w;

				float lRealDistance = max(0, -(lDistance - lTime * _RippleSpeed));
				float lRealDistanceHeight = max(0, -(lDistance - lTime * _RippleFoamSpeed));

				float3 lDirection = IN.worldPos.xyz - _WaterRipplePositions[p].xyz;

				float4 lWaves = float4(lDirection.xyz, 1) * sin(lRealDistance * _RippleFrequency);
				float4 lWhiteWaves = float4(1, 1, 1, 1) * ((sin(lRealDistanceHeight * _RippleFoamFrequency - (PI * 0.5)) + 1) / 2);

				float lRemaining = clamp(1 - (lTime / _RippleDuration), 0, 1);
				lRippleDir += lWaves * lRemaining * lRemaining * lRemaining;
				lRemaining = clamp(1 - (lTime / _RippleFoamDuration), 0, 1);
				lRippleHeight += lWhiteWaves * lRemaining;
			}

			lRippleHeight = saturate(lRippleHeight);
			lRippleHeightSave = lRippleHeight;

			if (_E_ToggleFoam) {
				/////////////////
				//Ripple Foam
				if (_UseRippleFoam) {
					float4 lNoise = (snoise(IN.worldPos.xyz * 0.9 + float3(_Time.y, 0, _Time.x) * _RippleFoamNoiseSpeed) + 1) / 2;
					lNoise += (snoise(IN.worldPos.xyz * 0.9 - float3(_Time.x, 0, -_Time.y) * _RippleFoamNoiseSpeed) + 1) / 2;

					lNoise /= 2;

					if (lNoise.r < 0.5) {
						lNoise = 1 - lNoise;
					}

					float4 lNoiseStitches = (snoise(IN.worldPos.xyz * (lRippleHeight.r * lRippleHeight.r * _RippleFoamStitches) + IN.worldPos.xyz + lRippleHeight.r + float3(snoise(lRippleDir.xyz), 0, snoise(lRippleDir.zyx)) * _RippleFoamStitches + _Time.y * _RippleFoamNoiseSpeed) + 1) / 2;

					if (lNoiseStitches.r > 0.5) {
						lNoiseStitches.rgb = 1 - lNoiseStitches.rgb;
					}

					lNoise -= (1 - lNoiseStitches);

					lRippleHeight -= lNoise + 0.5;

					if (lRippleHeight.r > _RippleFoamCut) {
						matched = 1;
					}
				}

				/////////////////
				//Edge Foam
				if (_UseEdgeFoam) {
					float4 lBorderNoise = (snoise(IN.worldPos.xyz * 0.9 + float3(_Time.y, 0, _Time.x) * _EdgeFoamNoiseSpeed) + 1) / 2;
					lBorderNoise += (snoise(IN.worldPos.xyz * 0.9 - float3(_Time.x, 0, -_Time.y) * _EdgeFoamNoiseSpeed) + 1) / 2;

					lBorderNoise /= 2;

					float4 lBorderNoiseStitches = (snoise(IN.worldPos.xyz * (IN.vertexColor.r * IN.vertexColor.r * 0.2) + IN.worldPos.xyz + IN.vertexColor.r + float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(_Time.y, 0, _Time.x) * _EdgeFoamNoiseSpeed) + 1) / 2;

					if (lBorderNoiseStitches.r > 0.5) {
						lBorderNoiseStitches.rgb = 1 - lBorderNoiseStitches.rgb;
					}

					lBorderNoiseStitches *= IN.vertexColor.r * 5;


					lBorderNoise += lBorderNoiseStitches * _EdgeFoamStitches;

					lBorderNoise -= (1 - (IN.vertexColor.r + 0.5)) * 1;

					if (lBorderNoise.r > _EdgeFoamCut) {
						matched = 1;
					}
				}
			}

			/////////////////
			//Overall Noise
			
			float3 lFoamOverlayNoise = float3(snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(_Time.y, 0, _Time.x) * _FoamTextureDistortSpeed), snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(-_Time.y, 0, _Time.x) * _FoamTextureDistortSpeed), snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(_Time.y, 0, -_Time.y) * _FoamTextureDistortSpeed));
			float3 lOverlayNoise = float3(snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(_Time.y, 0, _Time.x) * _OverlayTexDistortSpeed), snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(-_Time.y, 0, _Time.x) * _OverlayTexDistortSpeed), snoise(float3(snoise(IN.worldPos.xyz), 0, snoise(IN.worldPos.zyx)) + float3(_Time.y, 0, -_Time.y) * _OverlayTexDistortSpeed));
			
			/////////////////
			//Main
			float4 overlayColor = tex2D(_OverlayTex, IN.uv_OverlayTex + lOverlayNoise.xz * (_OverlayTexDistortStrength * 0.1));
			float4 underWatercolor = BlurProj(_GrabTexture, IN.grabPos + lRippleDir * _RippleRefractionStrength, _BlurIterations, _UnderWaterBlur);

			float4 finalColor = lerp(underWatercolor, overlayColor, overlayColor.a);
			finalColor = lerp(finalColor * _TintColor, _TintColor, _TintColor.a);

			finalColor = lerp(finalColor, underWatercolor, _Transparency);

			o.Normal = normalize(UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap)) + lerp(float3(0,0,1), lRippleDir.gbr, saturate((lRippleHeightSave.r * _RippleReflectionStrength))));

			/////////////////
			//Transparency
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			screenUV = float2(screenUV.x, 1 - screenUV.y);

			/////////////////
			//Screen Space Reflections
			if (_E_ToggleReflection) {
				float3 lEyeVec = normalize(IN.worldPos.xyz - _WorldSpaceCameraPos.xyz);
				float3 normal = normalize(o.Normal.rbg);
				float noiseScale = 100;
				normal = normalize(normal + float3(snoise(IN.worldPos.xyz * noiseScale) * _SSR_Noise, snoise(IN.worldPos.yzx * noiseScale) * _SSR_Noise, snoise(IN.worldPos.zxy * noiseScale) * _SSR_Noise));
				float3 reflection = reflect(lEyeVec, normal);

				float4 ssr_ReflectColor = SSR(_GrabTexture, _LastCameraDepthTexture, IN.worldPos.xyz, normal, reflection, _SSR_Iterations, _SSR_StepSize, _SSR_FadeSteps, _SSR_FadeDistance, _SSR_DebugDepth);
				finalColor.rgb = lerp(finalColor.rgb, ssr_ReflectColor.rgb, (1 - _SSR_Transparency));
			}

			/////////////////
			//Basic End
			if (matched == 1) {
				float4 lOverlay = tex2D(_FoamTextureOverlay, IN.uv_OverlayTex + lFoamOverlayNoise.xz * (_FoamTextureDistortStrength * 0.1));
				finalColor.rgb = lerp(finalColor.rgb, lOverlay.rgb * _FoamColor.rgb, _FoamColor.a);
			}

			o.Emission = lerp(float3(0, 0, 0), finalColor.rgb, saturate(_EmissionCut - Luminance(finalColor))) * _EmissionIntensity;

			/////////////////
			//Electric Shock
			if (_E_ToggleShock) {
				float3 lShockPos = _WaterShockPosition.xyz;
				float shockDistance = distance(_WaterShockPosition.xyz, IN.worldPos.xyz) + snoise(IN.worldPos.xyz);
				shockDistance -= (_Time.y - _WaterShockPosition.w) * _ShockSpeed;

				shockDistance = 1 - saturate(1 + shockDistance);

				float colorShockDistance = shockDistance * (1 - saturate((_Time.y - _WaterShockPosition.w) / (_ShockDuration)));

				float4 shockTexSpeedRaw = tex2D(_ShockTextureSpeed, float2(saturate((_Time.y - _WaterShockPosition.w) / (_ShockDuration - (_ShockDuration - _ShockEmissionDelay) + _ShockEmissionDuration)), 0.5));
				float shockTexSpeed = shockTexSpeedRaw.r + shockTexSpeedRaw.g + shockTexSpeedRaw.b;

				float inverseShock = 1 + (1 - colorShockDistance) * shockTexSpeed;
				float2 shockDisplace = float2(snoise(_Time.xy * shockTexSpeed * inverseShock) * shockTexSpeed * inverseShock, snoise(_Time.zy * shockTexSpeed * inverseShock) * shockTexSpeed * inverseShock);
				float4 shockColor = tex2D(_ShockTex, IN.uv_OverlayTex * _ShockTexScale + shockDisplace);

				float emissionShockDistance = shockDistance * (1 - saturate((_Time.y - _ShockEmissionDelay - _WaterShockPosition.w) / (_ShockEmissionDuration)));

				finalColor.rgb = lerp(finalColor.rgb, shockColor.rgb, colorShockDistance);
				o.Emission = lerp(o.Emission, shockColor.rgb * _ShockBasicBrightness, colorShockDistance);
				o.Emission = lerp(o.Emission, _ShockBrightness * _ShockBrightnessColor.rgb + shockColor.rgb * _ShockBrightness, emissionShockDistance * saturate((_Time.y - _ShockEmissionDelay - _WaterShockPosition.w) / (_ShockEmissionDuration)));
			}

			/////////////////
			//Final
			o.Albedo = finalColor.rgb;
			o.Smoothness = _Glossiness;
			o.Metallic = 0;
			o.Alpha = 1;
		}
		ENDCG
	}
	CustomEditor "Northwind.Shaders.InteractiveWater.Editors.NW_InteractiveWaterEditor"
}
