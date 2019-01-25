Shader "Custom/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_GridScale("Grid scale", Float) = 1
		_NumLevels("Num levels", Float) = 5
		_DotSizeMult("Dot size multiplier", Float) = .96
		_LuminancePower("Luminance power", Float) = 2
		_LuminanceLerp("Luminance lerp", Float) = .5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			sampler2D _DotTexture;
			float _GridScale;
			float _NumLevels;
			float _DotSizeMult;
			float _LuminancePower;
			float _LuminanceLerp;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv);
				float darkness = (1 - Luminance(texCol.rgb));

				float scaleIncrement = (1 / _NumLevels);
				//darkness = (darkness * 1.35) - .15;

				float scale = floor((darkness) / (1 / _NumLevels)) * scaleIncrement;
				_GridScale /= scale + .001;

				float stagger = fmod(floor(i.uv.y * _GridScale), 2);

				fixed2 dotUv = fixed2(i.uv.x * (_ScreenParams.x / _ScreenParams.y), i.uv.y) * _GridScale;
				dotUv.x += stagger * .5;
				float dotCol = step(scale * _DotSizeMult, length(frac(dotUv) - .5));

				return Luminance(lerp(fixed4(1, 1, 1, 1) * dotCol, pow((texCol.rgb), _LuminancePower), _LuminanceLerp));
            }
            ENDCG
        }
    }
}
