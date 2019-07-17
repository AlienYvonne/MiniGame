Shader "Unity Shaders Custom/Chapter 7/Single Texture" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss ("Gloss", Range(8.0,256)) = 0.5
		
	}
	SubShader {
		

		Pass{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
						o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
					
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));

				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 floatDir=normalize(viewDir+worldLightDir);
				fixed3 specular=_LightColor0.rgb*_Specular*pow(saturate(dot(worldNormal,floatDir)),_Gloss);
				return fixed4(ambient+diffuse,1.0f);
			}
			ENDCG
			}
		
		}
	FallBack "Diffuse"
}
