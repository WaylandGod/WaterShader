using UnityEngine;
using UnityEditor;
using System;
using Northwind.Editors.Shaders;

namespace Northwind.Shaders.InteractiveWater.Editors
{
    public class NW_InteractiveWaterEditor : ShaderGUI
    {
        enum BurnModes { Procedural, UV };
        enum WindModes { VertexHeight, VertexPainting };

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            MatEdit.SetScope(targetMat);

            /////////////////////////////////
            //Main
            if (MatEdit.BeginFoldGroup(new GUIContent("Main"), "_E_ToggleMain"))
            {
                EditorGUILayout.Space();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                MatEdit.ColorField(new GUIContent("Tint Color", "The color tint for the overlay texture"), "_TintColor");
                MatEdit.TextureField(new GUIContent("Overlay Texture", "The overlay texture"), "_OverlayTex");
                MatEdit.SliderField(new GUIContent("Distort Strength", "The distortion strength for the overlay texture"), "_OverlayTexDistortStrength", 0f, 1f);
                MatEdit.FloatField(new GUIContent("Distort Speed", "The distortion speed for the overlay texture"), "_OverlayTexDistortSpeed");
                MatEdit.SliderField(new GUIContent("Transparency", "The transparancy of the overlay aspects (Color + Texture)"), "_Transparency", 0, 1);
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space();

                MatEdit.NormalTextureField(new GUIContent("Normal Map", "The normal map for water"), "_NormalMap");

                MatEdit.SliderField(new GUIContent("Glossiness", "The glossiness of the Water"), "_Glossiness", 0, 1);

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Wind
            if (MatEdit.BeginToggleGroup(new GUIContent("Wind"), "_E_ToggleWind", MatEdit.GroupStyles.Main, false, true))
            {
                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Speed", "the wind speed"), "_WindSpeed", 0f, 1f);
                MatEdit.SliderField(new GUIContent("Strength", "the wind y distortion strength"), "_WindStrength", 0f, 0.5f);
                MatEdit.SliderField(new GUIContent("Scale", "the wind noise scaling"), "_WindScale", 0f, 1f);

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Ripples
            if (MatEdit.BeginToggleGroup(new GUIContent("Ripples"), "_E_ToggleRipples", MatEdit.GroupStyles.Main, false, true))
            {
                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Refraction Strength", "The ripple refraction strength"), "_RippleRefractionStrength", 0f, 1f);
                MatEdit.SliderField(new GUIContent("Reflection Strength", "The ripple reflection strength"), "_RippleReflectionStrength", 0f, 1f);
                MatEdit.SliderField(new GUIContent("Frequency", "The ripple frequency"), "_RippleFrequency", 0f, 10f);
                MatEdit.FloatField(new GUIContent("Expand Speed", "The ripple expand speed"), "_RippleSpeed");
                MatEdit.FloatField(new GUIContent("Duration", "The ripple duration"), "_RippleDuration");

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Foam
            if (MatEdit.BeginToggleGroup(new GUIContent("Foam"), "_E_ToggleFoam", MatEdit.GroupStyles.Main, false, true))
            {
                EditorGUILayout.Space();

                MatEdit.ColorField(new GUIContent("Color", "The color for the foam"), "_FoamColor");
                MatEdit.TextureField(new GUIContent("Overlay Texture", "The overlay texture"), "_FoamTextureOverlay");
                MatEdit.SliderField(new GUIContent("Distort Strength", "The distortion strength for the overlay texture"), "_FoamTextureDistortStrength", 0f, 1f);
                MatEdit.FloatField(new GUIContent("Distort Speed", "The distortion speed for the overlay texture"), "_FoamTextureDistortSpeed");

                EditorGUILayout.Space();

                if (MatEdit.BeginToggleGroup(new GUIContent("Ripple Foam", ""), "_UseRippleFoam", MatEdit.GroupStyles.Sub, false, true))
                {
                    MatEdit.SliderField(new GUIContent("Cut", "The cut value for the ripple foam"), "_RippleFoamCut", 0f, 1f);
                    MatEdit.SliderField(new GUIContent("Stitching", "The amount of stitching in the ripple foam"), "_RippleFoamStitches", 0f, 1f);
                    MatEdit.FloatField(new GUIContent("Noise Speed", "The ripple foam noise speed"), "_RippleFoamNoiseSpeed");
                    EditorGUILayout.Space();
                    MatEdit.SliderField(new GUIContent("Frequency", "The ripple foam frequency"), "_RippleFoamFrequency", 0f, 10f);
                    MatEdit.FloatField(new GUIContent("Expand Speed", "The ripple foam expand speed"), "_RippleFoamSpeed");
                    MatEdit.FloatField(new GUIContent("Duration", "The ripple foam duration"), "_RippleFoamDuration");
                }
                MatEdit.EndGroup();

                EditorGUILayout.Space();

                if (MatEdit.BeginToggleGroup(new GUIContent("Edge Foam", ""), "_UseEdgeFoam", MatEdit.GroupStyles.Sub, false, true))
                {
                    MatEdit.SliderField(new GUIContent("Cut", "The cut value for the edge foam"), "_EdgeFoamCut", 0f, 1f);
                    MatEdit.SliderField(new GUIContent("Stitching", "The amount of stitching in the edge foam"), "_EdgeFoamStitches", 0f, 1f);
                    MatEdit.FloatField(new GUIContent("Noise Speed", "The edge foam noise speed"), "_EdgeFoamNoiseSpeed");
                }
                MatEdit.EndGroup();

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Blur
            if (MatEdit.BeginFoldGroup(new GUIContent("Blur"), "_E_ToggleBlur"))
            {
                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Amount", "the blur spreading per iteration"), "_UnderWaterBlur", 0, 20);
                MatEdit.SliderField(new GUIContent("Iterations", "How many times should the image be blurred (WARNING: This value will be twice times to the power of 2 (2x^2))"), "_BlurIterations", 1, 10, true);

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Emission
            if (MatEdit.BeginFoldGroup(new GUIContent("Emission"), "_E_ToggleEmission"))
            {
                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Intensity", "The emission intensity"), "_EmissionIntensity", 0, 1);
                MatEdit.SliderField(new GUIContent("Cut", "The cut point for the light clamp"), "_EmissionCut", 0, 1);

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Reflection
            if (MatEdit.BeginToggleGroup(new GUIContent("SSR Reflection"), "_E_ToggleReflection", MatEdit.GroupStyles.Main, false, true))
            {
                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Transparency", "The transparency of the screen space reflection"), "_SSR_Transparency", 0, 1);

                EditorGUILayout.Space();

                MatEdit.SliderField(new GUIContent("Noise", "The missorientation of screen space reflection ray"), "_SSR_Noise", 0, 1);
                MatEdit.SliderField(new GUIContent("Iterations", "How many steps should be marshed on the ray"), "_SSR_Iterations", 0, 400, true);
                MatEdit.FloatField(new GUIContent("Step Size", "The quality level of the screen space reflection depends on the ray marshing step size (the lower = the better)"), "_SSR_StepSize");
                MatEdit.FloatField(new GUIContent("Fade Distance", "The fading of the reflection over distance"), "_SSR_FadeDistance");
                MatEdit.SliderField(new GUIContent("Fade Steps", "The step count for the fading at the end of the iterations"), "_SSR_FadeSteps", 0, targetMat.GetFloat("_SSR_Iterations"), true);

                EditorGUILayout.Space();

                MatEdit.ToggleField(new GUIContent("DEBUG: Depth", "DEBUG: Displays the depth of the reflection relative to the reflective surface"), "_SSR_DebugDepth");

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();

            /////////////////////////////////
            //Shock
            if (MatEdit.BeginToggleGroup(new GUIContent("Shock"), "_E_ToggleShock", MatEdit.GroupStyles.Main, false, true))
            {
                EditorGUILayout.Space();

                MatEdit.TextureField(new GUIContent("Texture", "The shock texture"), "_ShockTex");
                MatEdit.AnimationCurveField(new GUIContent("Texture Speed", "The texture displacement speed (x: 0 - 1 & y: 0 - 3)"), "_ShockTextureSpeed", 64);
                MatEdit.FloatField(new GUIContent("Texture Scale", "The shock texture scaling"), "_ShockTexScale");

                EditorGUILayout.Space();

                MatEdit.FloatField(new GUIContent("Expand Speed", "The speed the shock expands with"), "_ShockSpeed");

                EditorGUILayout.Space();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.LabelField("Intro", EditorStyles.boldLabel);
                MatEdit.FloatField(new GUIContent("Brightness", "The brightness for the intro"), "_ShockBasicBrightness");
                MatEdit.FloatField(new GUIContent("Duration", "The shock intro duration"), "_ShockDuration");
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.LabelField("Outro", EditorStyles.boldLabel);
                MatEdit.ColorField(new GUIContent("Brightness Tint", "The color tint for the emission"), "_ShockBrightnessColor");
                MatEdit.FloatField(new GUIContent("Brightness", "The shock outro brightness"), "_ShockBrightness");
                MatEdit.FloatField(new GUIContent("Delay", "The delay of the outro"), "_ShockEmissionDelay");
                MatEdit.FloatField(new GUIContent("Duration", "The duration the emission takes"), "_ShockEmissionDuration");
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space();
            }
            MatEdit.EndGroup();
        }
    }
}