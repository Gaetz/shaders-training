Shader "Custom/SpecularShaderForwardAdd" 
{
    Properties
    {
        _Color ("Color", Color) = (1,0,0,1)
        _DiffuseTex ("Texture", 2D) = "white" {}
        _Ambient ("Ambient", Range (0, 1)) = 0.25
        _SpecColor ("Specular Material Color", Color) = (1,1,1,1)     
	    _Shininess ("Shininess", Float) = 10
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase 
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float4 vertexWorld : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };
 
            sampler2D _DiffuseTex; 
            float4 _DiffuseTex_ST;
            float4 _Color;
            float _Ambient;
            float _Shininess;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normalDirection = normalize(i.worldNormal);
                float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));    
                float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));
 
                float4 tex = tex2D(_DiffuseTex, i.uv);
                
                // Diffuse
                float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
                float4 diffuseTerm = nl * _Color * tex * _LightColor0;
                
                //Specular implementation (Phong)
                float3 reflectionDirection = reflect(-lightDirection, normalDirection);
                float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
                float3 specular = pow(specularDot, _Shininess);
                float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;    
 
                // Add diffuse and specular
                float4 finalColor = diffuseTerm + specularTerm;
                return finalColor;
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }    
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD2;
                float4 vertexWorld : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };
 
            sampler2D _DiffuseTex; 
            float4 _DiffuseTex_ST;
            float4 _Color;
            float _Ambient;
            float _Shininess;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normalDirection = normalize(i.worldNormal);
                float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));    
                float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));
 
                float4 tex = tex2D(_DiffuseTex, i.uv);
                
                // Diffuse
                float nl = max(0.0, dot(normalDirection, _WorldSpaceLightPos0.xyz));
                float4 diffuseTerm = nl * _Color * tex * _LightColor0;
                
                //Specular implementation (Phong)
                float3 reflectionDirection = reflect(-lightDirection, normalDirection);
                float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
                float3 specular = pow(specularDot, _Shininess);
                float4 specularTerm = float4(specular, 1) * _SpecColor * _LightColor0;    
 
                // Add diffuse and specular
                float4 finalColor = diffuseTerm + specularTerm;
                return finalColor;
            }
            ENDCG
        }
    }
}
