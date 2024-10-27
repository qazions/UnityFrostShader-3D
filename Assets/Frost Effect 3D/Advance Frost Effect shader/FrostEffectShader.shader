Shader"Mobile/SharpIceFrostEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _FrostTex ("Frost Texture with Sharp Details", 2D) = "white" {} // Add texture with sharp icicle patterns
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _FreezeAmount ("Freeze Amount", Range(0,1)) = 0
        _ColorTint ("Frost Tint", Color) = (0.7, 0.9, 1.0, 1)
        _Smoothness ("Smoothness", Range(0,1)) = 0.2
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Sharpness ("Sharpness Intensity", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
LOD 300

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 2.0  // Ensures compatibility with mobile devices

sampler2D _MainTex;
sampler2D _FrostTex;
sampler2D _NormalMap;

float _FreezeAmount;
fixed4 _ColorTint;
half _Smoothness;
half _Metallic;
float _Sharpness;

struct Input
{
    float2 uv_MainTex;
    float2 uv_FrostTex;
    float2 uv_NormalMap;
};

void surf(Input IN, inout SurfaceOutputStandard o)
{
            // Sample base color
    fixed4 baseColor = tex2D(_MainTex, IN.uv_MainTex);

            // Sample frost texture with sharp details and apply color tint
    fixed4 frostColor = tex2D(_FrostTex, IN.uv_FrostTex) * _ColorTint;

            // Increase frost texture intensity based on FreezeAmount and Sharpness
    frostColor.rgb *= _FreezeAmount * _Sharpness;

            // Blend base and frost colors for a gradual freeze effect
    fixed4 finalColor = lerp(baseColor, frostColor, _FreezeAmount);

            // Apply normal map for added surface detail
    o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));

            // Set PBR values
    o.Albedo = finalColor.rgb;
    o.Smoothness = _Smoothness;
    o.Metallic = _Metallic;

            // Make the surface fully opaque by default
    o.Alpha = 1.0;
}
        ENDCG
    }
FallBack"Diffuse"
}
