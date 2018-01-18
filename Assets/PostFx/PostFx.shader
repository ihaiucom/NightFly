Shader "Hidden/Seido/PostFx"
{
    Properties
    {
        _MainTex("", 2D) = "black" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "SimplexNoise3D.hlsl"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    half4 _GradientA;
    half4 _GradientB;
    half4 _GradientC;
    half4 _GradientD;
    half _Frequency;
    half _Opacity;
    float _LocalTime;

    half3 Gradient(half x)
    {
        return saturate(_GradientA + _GradientB * cos(_GradientC * x + _GradientD));
    }

    struct Varyings
    {
        float4 position : SV_Position;
        float2 texcoord : TEXCOORD0;
    };

    Varyings Vertex(float4 position : POSITION, float2 texcoord : TEXCOORD0)
    {
        Varyings output;
        output.position = UnityObjectToClipPos(position);
        output.texcoord = texcoord;
        return output;
    }

    half4 Fragment(Varyings input) : SV_Target
    {
        half4 src = tex2D(_MainTex, input.texcoord);
        float3 p_n = float3(input.texcoord * _Frequency, _LocalTime);
        p_n.y *= 9.0 / 16;

        half sel = 1 + snoise(p_n) + src.r;
        half3 grad = Gradient(sel / 2);

        return fixed4(lerp(src, GammaToLinearSpace(grad), _Opacity), src.a);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
