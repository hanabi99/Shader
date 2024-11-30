using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson58 : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        #region 知识点一 开启深度写入的半透明效果是用来处理哪种需求的？
        //对于本身结构较为复杂的模型
        //使用之前的透明度混合Shader会由于关闭了深度写入
        //会产生错误的渲染效果

        //虽然我们可以通过拆分模型的方式解决部分问题
        //但是对于一些结构复杂的模型，拆分模型的方式会增加工作量

        //因此我们可以采用 开启深度写入的半透明Shader 来优化效果
        #endregion

        #region 知识点二 开启深度写入的半透明效果的基本原理
        //基本原理：
        //  使用两个Pass渲染通道来处理渲染逻辑
        //  第一个Pass：开启深度写入，不输出颜色
        //             目的是让该模型各片元的深度值能写入深度缓冲
        //  第二个Pass：进行正常的透明度混合（和上节课一样）

        //  这样做的话，当执行第一个Pass时，会执行深度测试，并进行深度写入
        //  如果此时该片元没有通过深度测试会直接丢弃，不会再执行第二个Pass
        //  对于同一个模型中处于屏幕同一位置的片元们，会进行该位置的深度测试再决定渲染哪个片元

        //  如何做到不输出颜色？
        //  使用 ColorMask 颜色遮罩 渲染状态(命令)
        //  它主要用于控制颜色分量是否写入到颜色缓冲区中
        //  ColorMask RGBA 表示写入颜色的RGBA通道
        //  ColorMask 0    表示不写入颜色
        //  ColorMask RB   表示只写入红色和蓝色通道

        //注意：
        //1.开启深度写入的半透明效果，模型内部之间不会有任何半透明效果（因为模型内部深度较大的片元会被丢弃掉）
        //2.由于有两个Pass渲染通道，因此它会带来一定的性能开销
        #endregion

        #region 知识点三 实现 开启深度写入的半透明效果
        //1.我们复制 Lesson57 中透明度混合的Shader代码
        //2.在SubShader中之前的Pass渲染通道前面加一个Pass渲染通道
        //3.在新加Pass渲染通道中开启深度写入，并且使用 ColorMask 0 颜色遮罩 渲染命令，不输出颜色
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
