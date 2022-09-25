Shader "Custom/PlanetRingShader"
{
    Properties{
         _RingColor("RingColor", Color) = (0,0,0,1)
         _Mask("Mask", 2D) = "white" {}
         _OuterRadius ("OuterRadius ", Range(0,1)) = 0.5
         _InnerRadius("InnerRadius", Range(0,1)) = 0.5
         _MainTex("Texture", 2D) = "white" {}
    }
        SubShader{
            Tags { "RenderType" = "Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
             #pragma surface surf Standard fullforwardshadows keepalpha
             #pragma target 3.0

             struct Input {
                float2 uv_Mask;
                float2 uv_MainTex;
                float4 color: COLOR;
             };

             fixed4 _RingColor;
             half _InnerRadius;
             half _OuterRadius ;
             sampler2D _MainTex;

             void surf(Input IN, inout SurfaceOutputStandard o) {

                 fixed x = (-0.5 + IN.uv_Mask.x) * 2;
                 fixed y = (-0.5 + IN.uv_Mask.y) * 2;

                 fixed radius = 1 - sqrt(x * x + y * y);
                 fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _RingColor;
                 clip(radius - _OuterRadius);

                 o.Albedo = color;
                 o.Alpha = 1;
                 if (radius > _InnerRadius) {
                     o.Alpha = 0;
                 }
             }
             ENDCG
         }
         FallBack "Diffuse"
}