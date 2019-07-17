// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Custom/Chapter 8/AlphaBlend BothSide" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1))=1
	}
	SubShader {
		Tags{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}

		CGINCLUDE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

		ENDCG

		Pass{
			Tags{ "LightMode"="ForwardBase" }
			Cull Front
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				

			fixed4 frag(v2f i) : SV_Target{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 normalDir = normalize(i.worldNormal);
				fixed4 albedo = tex2D(_MainTex,i.uv)*_Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*albedo.rgb;
				fixed3 diffuse = _LightColor0.rgb*albedo.rgb*max(dot(lightDir,normalDir),0);
				return fixed4(ambient+diffuse,albedo.a*_AlphaScale);
			}
			ENDCG
		}

		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			Cull Back
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag


			fixed4 frag(v2f i) : SV_Target{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 normalDir = normalize(i.worldNormal);
				fixed4 albedo = tex2D(_MainTex,i.uv)*_Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*albedo.rgb;
				fixed3 diffuse = _LightColor0.rgb*albedo.rgb*max(dot(lightDir,normalDir),0);
				return fixed4(ambient + diffuse,albedo.a*_AlphaScale);
			}
			ENDCG
			}
	}
	FallBack "Transparent/Cutout/VertexLit"
}
