Shader"Custom/RealisticFrostyIcicle"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _CrackTex ("Crack Texture", 2D) = "black" {}
        _FrostAmount ("Frost Amount", Range(0, 1)) = 0.0
        _IcicleScale ("Icicle Scale", Range(0, 1)) = 1.0
        _IceColor ("Ice Color", Color) = (0.8, 1.0, 1.0, 1.0)
        _CrackColor ("Crack Color", Color) = (0.0, 0.5, 1.0, 1.0)
        _DepthEffect ("Depth Effect", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
LOD 300

        Pass
        {
Blend SrcAlpha
OneMinusSrcAlpha
            Cull
Back
            ZWrite
On
            Lighting
On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

#include "UnityCG.cginc"

struct appdata_t
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float3 pos : TEXCOORD1; // Pass the world position
};

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _CrackTex;
float _FrostAmount;
float _IcicleScale;
float4 _IceColor;
float4 _CrackColor;
float _DepthEffect;

v2f vert(appdata_t v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;

                // Adjust the position of the vertices for icicle effect
    float frostHeight = _IcicleScale * _FrostAmount * 0.2;
    o.vertex.xyz += v.normal * frostHeight;

    o.normal = v.normal;
    o.pos = mul(unity_ObjectToWorld, v.vertex).xyz; // Convert to world space
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
                // Sample textures
    fixed4 baseColor = tex2D(_MainTex, i.uv);
    fixed4 normalColor = tex2D(_NormalMap, i.uv);
    fixed4 crackTexture = tex2D(_CrackTex, i.uv);

                // Frost effect
    float frostEffect = _FrostAmount;
    fixed4 iceEffectColor = _IceColor * frostEffect;
    baseColor.rgb = lerp(baseColor.rgb, iceEffectColor.rgb, frostEffect);

                // Calculate crack effect based on frost amount
    float crackEffect = smoothstep(0.2, 0.8, frostEffect);
    fixed4 finalCrackColor = _CrackColor * crackTexture.a * crackEffect;

                // Blend cracks with base color
    baseColor.rgb += finalCrackColor.rgb;

                // Add depth effect to enhance realism
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.pos);
    float3 lightDir = normalize(_WorldSpaceLightPos0 - i.pos);
    float3 halfVec = normalize(viewDir + lightDir);
    float NdotL = max(0, dot(i.normal, lightDir));

                // Set a minimum ambient occlusion effect even when frost is not applied
    float ambientOcclusion = 0.3; // Adjust this value as needed
    baseColor.rgb *= (NdotL + ambientOcclusion); // Darken the color based on normals and lighting

                // Depth effect
    float depthFactor = _DepthEffect * frostEffect;
    baseColor.rgb += normalColor.rgb * depthFactor;

                // Set alpha to 1 (fully opaque)
    baseColor.a = 1.0;

    return baseColor;
}
            ENDCG
        }
    }
FallBack"Diffuse"
}
