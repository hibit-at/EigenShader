Shader "Custom/EigenShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_N_Grid("N_Grid", 2D) = "white"{}
		_T_Grid("T_Gird", 2D) = "white"{}
		_Bases("Bases", 2D) = "white"{}
		_EigenAxes("EigenAxes", 2D) = "white"{}
		_A("A",Range(-10,10)) = 0
		_B("B",Range(-10,10)) = 0
		_C("C",Range(-10,10)) = 0
		_D("D",Range(-10,10)) = 0
		_Scale("Scale",Range(0,10)) = 5
		_GridOpacity("GridOpacity",Range(0,1)) = 0
		_EigenOpacity("EigenOpacity",Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _T_Grid;
			sampler2D _N_Grid;
			sampler2D _Bases;
			sampler2D _EigenAxes;
			float _A;
			float _B;
			float _C;
			float _D;
			float _Scale;
			float _GridOpacity;
			float _EigenOpacity;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 xy = float2(i.uv.x,i.uv.y);
				xy -= .5;
				float lambda1 = (_A+_D)/2+sqrt(pow(_A-_D,2)+4*_B*_C)/2;
				float lambda2 = (_A+_D)/2-sqrt(pow(_A-_D,2)+4*_B*_C)/2;
				float theta1 = atan2(lambda1-_A,_B);
				float theta2 = atan2(lambda2-_A,_B);
				theta1 = atan2(_C,lambda1-_D);
				theta2 = atan2(_C,lambda2-_D);
				float2x2 eigenrot1 = float2x2(cos(theta1),sin(theta1),-sin(theta1),cos(theta1));
				float2x2 eigenrot2 = float2x2(cos(theta2),sin(theta2),-sin(theta2),cos(theta2));
				float2 eigenxy1 = mul(eigenrot1,xy);
				half4 c5 = tex2D(_EigenAxes,eigenxy1+.5);
				float2 eigenxy2 = mul(eigenrot2,xy);
				half4 c6 = tex2D(_EigenAxes,eigenxy2+.5);
				float det = _A*_D-_B*_C;
				float2x2 trans = float2x2(_D,-_B,-_C,_A);
				xy =_Scale*2*xy;
				half4 c4 = tex2D(_N_Grid,xy);
				xy = mul(trans,xy)/det;
				fixed4 c = tex2D(_MainTex, xy);
				half4 c2 = tex2D(_T_Grid, xy);
				half4 c3 = tex2D(_Bases, xy);
				if (pow(_A-_D,2)+4*_B*_C < 0) {
					_EigenOpacity = 0;
				}
				c.rgb = lerp(c.rgb, c2.rgb, c2.a);
				c.rgb = lerp(c.rgb, c3.rgb, c3.a);
				c.rgb = lerp(c.rgb, c4.rgb, c4.a*_GridOpacity);
				c.rgb = lerp(c.rgb, c5.rgb, c5.a*_EigenOpacity);	
				c.rgb = lerp(c.rgb, c6.rgb, c6.a*_EigenOpacity);
				return c;
			}
			ENDCG
		}
	}
}
