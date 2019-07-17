Shader "MiniGame/Cylinder" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		[NoScaleOffset] _TopTex("Top Tex(Y+)", 2D) = "white" {}
		[NoScaleOffset] _BottomTex("Bottom Tex(Y-)", 2D) = "white" {}
		_SideTex ("Side Tex", 2D) = "white" {}

		_StartColor("Color", Color) = (1,1,1,1)
		_EndColor("Color", Color) = (1,1,1,1)
		_Height("Height", Range(0,1)) = 0.5
		_Intensity("Intensity", Float) = 0.5
		_Speed("Speed", Range(1,30)) = 5
	}
	SubShader {

		CGINCLUDE
			
			#include "CalculateAngle.cginc"
			#include "Lighting.cginc"
			#define PRESICION 1.0f-10e-5

			fixed4 _Color;
			sampler2D _TopTex;
			sampler2D _BottomTex;
			sampler2D _SideTex;
			float4 _SideTex_ST;


			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD0;
				fixed4 uv: TEXCOORD1;
				
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.uv.xy = v.texcoord.xy;
				o.uv.zw = v.texcoord.xy * _SideTex_ST.xy + _SideTex_ST.zw;
				return o;
			}

		ENDCG
		

		Pass{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag



			fixed4 frag(v2f i) : SV_Target{
				fixed4 finalCol = fixed4(1.0f,1.0f,1.0f,1.0f);
				if (i.vertex.y >= PRESICION) {
					//finalCol= fixed4(0.2f, 0.3f, 1.0f, 1.0f);
					finalCol = tex2D(_TopTex, i.uv.xy);
				}
				else if (-i.vertex.y >= PRESICION) {
					finalCol = tex2D(_BottomTex, i.uv.xy);
				}
				else{
					//finalCol= fixed4(0.2f, 0.3f, 1.0f, 1.0f);
					finalCol = tex2D(_SideTex, i.uv.zw);
				}
				
				return finalCol;
				//fixed4 finalCol = tex2D(_MainTex,i.uv);
				//return fixed4(finalCol.rgb,1.0f);
			}
			ENDCG
			}
		
			Pass
			{
				Name "AtmosphereBase"
				Tags{ "LightMode" = "Always" }
				//Cull Front
				Blend SrcAlpha One

				CGPROGRAM

					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"

					uniform float4 _StartColor;
					uniform float4 _EndColor;
					uniform float _Height;
					uniform float _Intensity;
					uniform float _Speed;

					struct vertexOutput
					{
						float4 pos:SV_POSITION;
						float4 vertex:TEXCOORD2;
					};

					vertexOutput vert(appdata_base v)
					{
						vertexOutput o;
						float3 origin = float3(0,0,1);
						float scale = saturate(1-abs(dot(v.normal,float3(0,1,0))));
						float3 dir = float3(v.vertex.x,0.01,v.vertex.z);
						//顶点位置以法线方向向外延伸
						v.vertex.xyz += dir * _Height;
						o.pos = UnityObjectToClipPos(v.vertex);

						o.vertex = v.vertex;
						return o;
					}

					float4 frag(vertexOutput i) :COLOR
					{
						float angle = CalculateAngle(float2(0,1),float2(i.vertex.x,i.vertex.z));
						//float num = (floor(angle / 30)) / 12.f;
						angle += _Speed*_Time.y*10;
						float num = radians(angle);
						num = (sin(num)+1)/2;
						
						//float l = abs(_SinTime.w);
						
						fixed4 color = lerp(_StartColor,_EndColor,num);
						
						color.a *= _Intensity;
						return color;
					}
			ENDCG
			}

		}
	FallBack "Diffuse"
}
