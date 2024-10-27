Shader"Unlit/FrostEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _FrostTex ("Frost Texture", 2D) = "white" {}
        _FreezeAmount ("Freeze Amount", Range(0,1)) = 0
        _ColorTint ("Frost Tint", Color) = (0.7, 0.9, 1.0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma target 2.0 // Ensures compatibility with most Android devices

#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
    float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
sampler2D _FrostTex;
float4 _MainTex_ST;
float _FreezeAmount;
float4 _ColorTint;

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    UNITY_TRANSFER_FOG(o, o.vertex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
                // Sample the base texture
    fixed4 baseColor = tex2D(_MainTex, i.uv);

                // Sample the frost texture
    fixed4 frostColor = tex2D(_FrostTex, i.uv);

                // Apply color tint to frost texture
    fixed4 tintedFrost = frostColor * _ColorTint;

                // Blend base and frost based on FreezeAmount
    fixed4 finalColor = lerp(baseColor, tintedFrost, _FreezeAmount);

                // Apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    return finalColor;
}
            ENDCG
        }
    }
FallBack"Diffuse"
}
