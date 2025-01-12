using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson97 : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        #region 知识回顾 如何让物体投射阴影
        //对应知识点 Lesson66_不透明物体阴影_让物体投射阴影

        //物体向其它物体投射阴影的关键点是：
        //1. 需要实现 LightMode(灯光模式) 为 ShadowCaster(阴影投射) 的 Pass(渲染通道)
        //   这样该物体才能参与到光源的阴影映射纹理计算中

        //2. 一个编译指令，一个内置文件，三个关键宏
        //  编译指令：
        //  #pragma multi_compile_shadowcaster
        //  该编译指令时告诉Unity编译器生成多个着色器变体
        //  用于支持不同类型的阴影（SM，SSSM等等）
        //  可以确保着色器能够在所有可能的阴影投射模式下正确渲染

        //  内置文件：
        //  #include "UnityCG.cginc"
        //  其中包含了关键的阴影计算相关的宏

        //  三个关键宏:
        //  2-1.V2F_SHADOW_CASTER
        //    顶点到片元着色器阴影投射结构体数据宏
        //    这个宏定义了一些标准的成员变量
        //    这些变量用于在阴影投射路径中传递顶点数据到片元着色器
        //    我们主要在结构体中使用
        //  2-2.TRANSFER_SHADOW_CASTER_NORMALOFFSET
        //    转移阴影投射器法线偏移宏
        //    用于在顶点着色器中计算和传递阴影投射所需的变量
        //    主要做了
        //    2-2-1.将对象空间的顶点位置转换为裁剪空间的位置
        //    2-2-2.考虑法线偏移，以减轻阴影失真问题，尤其是在处理自阴影时
        //    2-2-3.传递顶点的投影空间位置，用于后续的阴影计算
        //    我们主要在顶点着色器中使用
        //  2-3.SHADOW_CASTER_FRAGMENT
        //    阴影投射片元宏
        //    将深度值写入到阴影映射纹理中
        //    我们主要在片元着色器中使用

        //3.利用这些内容在Shader中实现代码

        //由于投射阴影相关的代码较为通用
        //因此建议大家不用自己去实现相关Shader代码
        //直接通过FallBack调用Unity中默认Shader中的相关代码即可
        #endregion

        #region 知识点回顾 透明度混合物体投射阴影
        //对应知识点 Lesson70_透明物体阴影_透明度混合物体阴影实现

        //由于透明度混合需要关闭深度写入
        //而阴影相关的处理需要用到深度值参与计算
        //因此Unity中从性能方面考虑（要计算半透明物体的的阴影表现效果是相对复杂的）
        //所有的内置半透明Shader都不会产生阴影效果（比如 Transparent/VertexLit）
        //因此
        //2-1.透明混合Shader想要 投射阴影时
        //    不管你在FallBack中写入哪种自带的半透明混合Shader
        //    都不会有投射阴影的效果，因为深度不会写入

        //2-2.透明混合Shader想要 接受阴影时
        //    Unity内置关于阴影接收计算的相关宏
        //    不会计算处理 透明混合Shader
        //    混合因子 设置为半透明效果(Blend SrcAlpha OneMinusSrcAlpha)的Shader 
        //    因为透明混合物体的深度值和遮挡关系无法直接用传统的深度缓冲和阴影贴图来处理

        //结论：
        //Unity中不会直接为透明度混合Shader处理阴影

        //强制投射：
        //在FallBack中设置一个非透明Shader，比如VertexLit、Diffuse等
        //用其中的灯光模式设置为阴影投射的渲染通道来参与阴影映射纹理的计算
        //把该物体当成一个实体物体处理
        #endregion

        #region 知识点一 顶点动画物体投射阴影
        //我们可以为有顶点动画的物体 使用 LightMode(灯光模式) 为 ShadowCaster(阴影投射) 的 Pass(渲染通道)
        //这样它便能投射阴影
        //但是如果我们直接使用内置的这种Pass（默认Shader中的，通过FallBack寻找到的）
        //投射的阴影会是不正确的，因为默认Pass当中并不会使用新的顶点位置来投射
        //而是按照模型原来的顶点位置来计算阴影的
        //举例：
        //1.新建一个Shader,复制 Lesson94_2DWater 流动的2D河流的Shader代码
        //2.为其加上一个不透明的FallBackShader 比如VertexLit
        //3.在Mesh Renderer中开启双面投射阴影

        //这时我们使用该Shader投射出来的阴影是没有经过顶点动画变化的模型阴影
        #endregion

        #region 知识点二 让顶点动画物体投射正确的阴影
        //我们需要自定义一个LightMode(灯光模式) 为 ShadowCaster(阴影投射) 的 Pass(渲染通道)
        //在顶点着色器函数中进行顶点相关的计算
        //1.为知识点一种创建的Shader复制基础阴影投射渲染通道代码 Lesson64_ForwardLighting 中注释掉的Pass
        //2.在该Pass中加入 波形频率、波长的倒数、波形幅度 属性的映射
        //3.在该Pass中的顶点着色器函数中 加入顶点的偏移计算（直接复制前面的代码）
        //4.直接对模型空间中顶点进行偏移，不用进行裁剪坐标空间变换以及UV相关计算
        #endregion

        #region 总结
        //想要让带有顶点动画的对象产生正确的阴影
        //我们需要自定义 投射阴影的Pass（渲染通道）
        //在其中加入对顶点的变换计算即可
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
