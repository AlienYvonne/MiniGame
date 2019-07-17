Shader "MiniGame/CubeBlend(Single)" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_TopTex("Top Tex(Y+)", 2D) = "white" {}
		_BottomTex("Bottom Tex(Y-)", 2D) = "white" {}
		_LeftTex ("Left Tex(X+)", 2D) = "white" {}
		_RightTex("Right Tex(X-)", 2D) = "white" {}
		_FrontTex("Front Tex(Z+)", 2D) = "white" {}
		_BehindTex("Behind Tex(Z-)", 2D) = "white" {}
		
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}
	SubShader {
		
		Tags{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		CGINCLUDE
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#define PRESICION 0.5f-10e-5

			fixed4 _Color;
			sampler2D _TopTex;
			sampler2D _BottomTex;
			sampler2D _LeftTex;
			sampler2D _RightTex;
			sampler2D _FrontTex;
			sampler2D _BehindTex;

			float4 _LeftTex_ST;
			float4 _RightTex_ST;
			float4 _TopTex_ST;
			float4 _BottomTex_ST;
			float4 _FrontTex_ST;
			float4 _BehindTex_ST;

			float _AlphaScale;


			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD0;
				//top bottom
				fixed4 uv1 : TEXCOORD1;
				//left right
				fixed4 uv2 : TEXCOORD2;
				//front behind
				fixed4 uv3 : TEXCOORD3;
			};
		ENDCG

		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.vertex = v.vertex;
				o.uv1.xy = v.texcoord.xy * _TopTex_ST.xy + _TopTex_ST.zw;
				o.uv1.zw = v.texcoord.xy * _BottomTex_ST.xy + _BottomTex_ST.zw;
				o.uv2.xy = v.texcoord.xy*_LeftTex_ST.xy+_LeftTex_ST.zw;
				o.uv2.zw = v.texcoord.xy * _LeftTex_ST.xy + _LeftTex_ST.zw;
				o.uv3.xy = v.texcoord.xy * _FrontTex_ST.xy + _FrontTex_ST.zw;
				o.uv3.zw = v.texcoord.xy * _BehindTex_ST.xy + _BehindTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed4 finalCol = fixed4(1.0f,1.0f,1.0f,1.0f);
				if (i.vertex.x >= PRESICION) {
					//finalCol= fixed4(0.2f, 0.3f, 1.0f, 1.0f);
					finalCol = tex2D(_LeftTex,i.uv1.xy);
				}
				else if (-i.vertex.x >= PRESICION) {
					finalCol = tex2D(_RightTex, i.uv1.xy);
				}
				else if (i.vertex.y >= PRESICION) {
					//finalCol= fixed4(0.2f, 0.3f, 1.0f, 1.0f);
					finalCol = tex2D(_TopTex, i.uv1.xy);
				}
				else if (-i.vertex.y >= PRESICION) {
					finalCol = tex2D(_BottomTex, i.uv1.xy);
				}
				else if (i.vertex.z >= PRESICION) {
					//finalCol= fixed4(0.2f, 0.3f, 1.0f, 1.0f);
					finalCol = tex2D(_FrontTex, i.uv1.xy);
				}
				else if (-i.vertex.z >= PRESICION) {
					finalCol = tex2D(_BehindTex, i.uv1.xy);
				}

				//fixed4 finalCol = tex2D(_MainTex,i.uv);
				return fixed4(finalCol.rgb, _AlphaScale);
			}
			ENDCG
			}
		
		}
	FallBack "Transparent/Cutout/VertexLit"
}
