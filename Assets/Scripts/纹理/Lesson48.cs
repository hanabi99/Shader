using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson48 : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        #region 知识回顾 内置函数——二维纹理采样函数
        //fixed4 tex2D(sampler2D tex, float2 s)
        //传入纹理图片和uv坐标
        //返回纹理图片中对应位置的颜色值
        #endregion

        #region 知识点 书写单张纹理颜色采样Shader

        #region 第一步 完成Shader文件基本结构，让其不报错
        #endregion

        #region 第二步 纹理属性和CG成员变量声明
        //  关键知识点
        //  CG中映射ShaderLab中的纹理属性，需要有两个成员变量
        //  一个用于映射纹理颜色数据，一个用于映射纹理缩放平移数据
        //
        //  ShaderLab中的属性
        //  图片属性（2D）
        //  用于利用UV坐标提取其中颜色

        //  CG中用于映射属性的成员变量
        //  1.sampler2D 用于映射纹理图片
        //  2.float4    用于映射纹理图片的缩放和平移
        //              固定命名方式 纹理名_ST (S代表scale缩放 T代表translation平移)
        #endregion

        #region 第三步 用缩放平移参数参与uv值计算
        //1.如何获取模型中携带的uv信息？
        //  在顶点着色器中，我们可以利用TEXCOORD语义获取到模型中的纹理坐标信息
        //  它是一个float4类型的
        //  xy获取到的是纹理坐标的水平和垂直坐标
        //  zw获取到的是纹理携带的一些额外信息，例如深度值等

        //2.如何计算
        //  固定算法
        //  先缩放，后平(偏)移
        //  缩放用乘法，平(偏)用加法
        //  纹理坐标.xy * 纹理名_ST.xy + 纹理名_ST.wz
        //  或者直接用内置宏
        //  TRANSFORM_TEX(纹理坐标变量, 纹理变量)
        //  该宏在内部会进行相同的计算
        #endregion

        #region 第四步 在片元着色器中进行纹理颜色采样

        #endregion

        #endregion

        #region 总结
        //纹理颜色采样非常简单
        //1.顶点着色器中获取到模型中的纹理坐标信息
        //  进行相关的缩放偏移计算后返回
        //2.片元着色器得到插值后的uv坐标进行纹理采样
        //  返回对应的颜色
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
