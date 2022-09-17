Shader "Custom/Atmosphere" 
{
	Properties
	{
		_MainTex("Texture1", 2D) = "white" {} // текстура1
		_Color("Color (RGBA)", Color) = (1, 1, 1, 1)
		_AtmosphereRadius("AtmosphereRadius", float) = 1.1 // Радиус атмосферы
		_PlanetRadius("PlanetRadius", float) = 1 // Радиус 
	}

	SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			CGPROGRAM

			#pragma vertex vert alpha
			#pragma fragment frag alpha

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex  : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f result;
				result.vertex = UnityObjectToClipPos(v.vertex);
				result.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return result;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) ; // multiply by _Color
				return col;
			}

			ENDCG
		}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert alpha
			#pragma fragment frag alpha

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _AtmosphereRadius; // радиус
			float _PlanetRadius; // радиус

			fixed4 _EmissionColor;
			half _Glossiness;

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex  : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};
			struct Input {
				float2 uv_MainTex;
			};


			v2f vert(appdata_full v)
			{
				v2f result;
				v.vertex.xyz += v.normal * (_AtmosphereRadius - _PlanetRadius); 
				result.vertex = UnityObjectToClipPos(v.vertex);
				result.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return result;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col =  _Color;  
				return col;
			}
			
			ENDCG
		}
	}
}