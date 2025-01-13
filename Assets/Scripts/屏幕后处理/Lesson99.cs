using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson99 : MonoBehaviour
{
    public Color color;
    [Range(0,1)]
    public float fresnelScale;

    private Material material;

    // Start is called before the first frame update
    void Start()
    {
        //获取对象的渲染器
        Renderer renderer = GetComponent<Renderer>();
        if(renderer != null)
        {
            //sharedMaterial和material的区别
            //sharedMaterial:一个是改一个都变
            //material:一个是改一个不会影响其它使用相同材质球的对象
            //得到主材质球
            material = renderer.material;//renderer.sharedMaterial;
            //得到所有的材质球
            //Material[] materials = renderer.sharedMaterials; //renderer.materials;
            //修改颜色
            //material.color = color;
            //修改主纹理
            //material.mainTexture = Resources.Load<Texture2D>("路径");

            //if(material.HasColor("_Color"))
            //{
            //    material.SetColor("_Color", color);
            //    print(material.GetColor("_Color"));
            //}
                

            //if(material.HasFloat("_FresnelScale"))
            //    material.SetFloat("_FresnelScale", fresnelScale);

            //修改渲染队列
            //material.renderQueue = 2000;

            //修改材质球使用的shader
            //material.shader = Shader.Find("Unlit/Lesson80_Fresnel");

            //material.SetTextureOffset("_MainTex", new Vector2(0.5f, 0.5f));
            //material.SetTextureScale("_MainTex", new Vector2(0.5f, 0.5f));
        }

        #region 知识回顾
        //Mesh Renderer(网格渲染器)
        //  └── Mesh(网格) —— MeshFilter(网格过滤器组件进行关联)
        //        └── Geometry Data(几何数据)
        //  └── Material(材质)
        //        └── Shader(着色器)
        //        └── Properties(属性：颜色、纹理等 —— 在Shader中决定哪些属性暴露在材质上)

        //Skinned Mesh Renderer(蒙皮网格渲染器)
        //  └── Mesh(网格)
        //        └── Geometry Data(几何数据)
        //  └── Bones & Weights(骨骼与权重)
        //  └── Material(材质)
        //        └── Shader(着色器)
        //        └── Properties(属性：颜色、纹理等 —— 在Shader中决定哪些属性暴露在材质上)
        #endregion

        #region 知识点一 如何得到对象使用的材质
        //1.获取到对象的渲染器Renderer 
        //  Mesh Renderer和Skinned Mesh Renderer都继承Renderer
        //  我们可以用里式替换原则父类获取、装载子类对象
        //2.通过渲染器获取到对应材质
        //  我们可以利用渲染器中的material或者sharedMaterial来获取物体的材质
        //  如果存在多个材质，可以使用renderer.materials或renderer.sharedMaterials来获取

        //material和sharedMaterial的区别
        //material:
        //material属性会返回对象的实例化材质, 相当于它会为对象创建一个该材质的独立副本
        //当你通过material属性修改材质时，这些更改只会影响这个特定对象，而不会影响使用相同材质的其他对象
        //使用material会增加内存消耗，因为每个对象都有自己独立的材质副本，但是可以单独修改单个对象

        //sharedMaterial:
        //sharedMaterial属性会返回对象的共享材质，相当于它返回的是所有使用这个材质的对象共享的同一个材质实例
        //当你通过sharedMaterial属性修改材质时，这些更改会影响所有使用这个材质的对象
        //使用sharedMaterial不会增加内存消耗，但是会批量修改所有使用该材质的对象
        #endregion

        #region 知识点二 如何修改材质属性
        //1.颜色
        //  材质对象中有color成员用于颜色修改
        //2.纹理
        //  材质对象中有mainTexture成员用于主纹理修改
        //3.通用修改方式
        //  材质中有各种Set方法，用于修改属性
        //  通过传入属性名，以及对应值进行赋值
        //  注意：属性值以SubShader中声明的属性名为准，而不是面板上的显示
        //4.修改Shader
        //  调用材质中shader属性进行修改
        //  利用Shader.Find(Shader名)方法得到对应Shader
        #endregion

        #region 知识点三 材质中常用方法
        //除了刚才学习的修改属性的相关方法
        //材质中还有：
        //1.判断某类型指定名字属性是否存在
        //2.获取某个属性值
        //3.修改渲染队列
        //4.设置纹理缩放偏移
        //等等
        #endregion

        #region 总结
        //Unity中想要通过C#代码修改Shader相关参数信息
        //我们一般都是通过材质去进行修改的
        //需要使用材质提供的各种相关方法进行修改
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        if (material.HasColor("_Color"))
        {
            material.SetColor("_Color", color);
            print(material.GetColor("_Color"));
        }


        if (material.HasFloat("_FresnelScale"))
            material.SetFloat("_FresnelScale", fresnelScale);
    }
}
