using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson59 : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        #region 知识点一 双面渲染的透明效果用来处理哪种需求的？
        //对于现实世界的半透明物体，我们不仅可以透过它看到其他物体的样子
        //也可以看到这个物体自己的内部结构
        //但是我们之前实现的 透明度测试 和 透明度混合 相关Shader
        //都无法看到模型的内部结构

        //而双面渲染的透明效果Shader就是来解决该问题的
        //让我们不仅可以透过半透明物体看到其他物体的样子还可以看到自己的内部结构
        #endregion

        #region 知识点二 双面渲染的透明效果的基本原理
        //基本原理：
        //  默认情况下，Unity会自动剔除物体的背面，而只渲染物体的正面
        //  双面渲染的基本原理就是利用我们之前学习过的 Cull 剔除指令来进行指定操作
        //  Cull Back     背面剔除
        //  Cull Front    正面剔除
        //  Cull Off      不剔除
        //  不设置的话，默认为背面剔除

        //  对于透明度测试Shader
        //  由于它无需混合，因此我们直接 关闭剔除即可

        //  对于透明度混合Shader
        //  由于它需要进行混合
        //  需要使用两个Pass，一个用于渲染背面，一个用于渲染正面
        //  两个Pass中除了剔除命令不同 其他代码和之前一致
        #endregion

        #region 知识点三 实现 双面渲染的透明效果Shader
        //透明度测试
        //  1.复制 Lesson56 透明度测试相关Shader代码
        //  2.在Pass中关闭剔除 Cull Off

        //透明度混合
        //  1.复制 Lesson57 透明度混合相关Shader代码
        //  2.复制之前的Pass，变成两个一模一样的Pass
        //  3.在第一个Pass中剔除正面 Cull Front，在第二个Pass中剔除背面Cull Back
        //    相当于一个片元先渲染背面再渲染正面
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
